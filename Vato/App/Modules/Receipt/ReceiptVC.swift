//
//  ReceiptVC.swift
//  Vato
//
//  Created by THAI LE QUANG on 9/17/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import VatoNetwork
import Alamofire
import RxSwift
import FwiCore
import SnapKit

@objc protocol ReceiptVCDelegate: class {
    func dismissTrip()
}

class ReceiptVC: UIViewController {
    
    //MARK :- Outlet
    @IBOutlet weak var imgDriverAvatar: FCImageView?//
    @IBOutlet weak var lblDriverName: UILabel?
    @IBOutlet weak var lblCarName: UILabel?
    @IBOutlet weak var lblCarCode: UILabel?
    
    @IBOutlet weak var btnCallDriver: UIButton?
    @IBOutlet weak var btnBlock: UIButton?
    
    @IBOutlet weak var  lblFare: UILabel?
    @IBOutlet weak var  lblFareValue: UILabel?
    @IBOutlet weak var  lblPromotion: UILabel?
    @IBOutlet weak var  lblPromotionValue: UILabel?
    
    @IBOutlet weak var  lblPaymentBy: UILabel?
    @IBOutlet weak var  lblTotalPrice: UILabel?
    
    @IBOutlet weak var btnDismiss: UIButton?
    @IBOutlet weak var containerDirection: UIView?
    
    
    private var book: FCBooking?
    private var driverPhone: String?
    
    lazy var disposeBag = DisposeBag()
    
    @objc weak var delegate: ReceiptVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
    }
    
    @objc func setDelegate(delegate: ReceiptVCDelegate?) {
        self.delegate = delegate
    }
    
    @objc func setBookInfo(book: FCBooking) {
        self.book = book
    }
    
    @IBAction func callDriver(_ sender: Any) {
        guard let phone = self.driverPhone, let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func blockClicked(_ sender: Any) {
        guard let driverUserId = self.book?.info.driverUserId else { return }
        
        UserDataHelper.shareInstance().getAuthToken { [weak self](t, e) in
            guard let wSelf = self, let token = t, token.count > 0 else { return }
            Requester.request(using: VatoAPIRouter.addDriverToBlacklist(token: token, userID: Int64(driverUserId)), method: .post, encoding: JSONEncoding.default).subscribe(onNext: { [weak self](response, data) in
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let isOK = json?["data"] as? Bool ?? false
                if response.statusCode == 200 && isOK {
                    self?.blockDriver()
                }
            }).disposed(by: wSelf.disposeBag)
        }
        
        showRatingView()
    }
    
    @IBAction func didtouchDismiss(_ sender: Any) {
        showRatingView()
    }
    
    // MARK: - Private methods
    private func setupNavigationBar() {
        UIApplication.setStatusBar(using: .lightContent)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        self.title = Text.receipt.localizedText
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar?.shadowImage = UIImage()
        
        if #available(iOS 12, *) {
        } else {
            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
                $0.isHidden = true
            })
        }
        
        UIApplication.setStatusBar(using: .lightContent)
    }
    
    private func setupView() {
        btnCallDriver?.setTitle(Text.callDriver.localizedText, for: .normal)
        btnBlock?.setTitle(Text.blockDriver.localizedText, for: .normal)
        lblFare?.text = Text.fare.localizedText
        lblPromotion?.text = Text.promotion.localizedText
        btnDismiss?.setTitle(Text.dismiss.localizedText, for: .normal)
        
        guard let book = self.book else { return }
        
        FirebaseHelper.shareInstance()?.getDriver(book.info.driverFirebaseId, handler: { [weak self](driver) in
            if let url = driver?.user.avatarUrl {
                self?.imgDriverAvatar?.setImageWithUrl(url)
            }
            self?.lblDriverName?.text = driver?.user.fullName ?? ""
            self?.lblCarName?.text = driver?.vehicle.marketName ?? ""
            self?.lblCarCode?.text = driver?.vehicle.plate ?? ""
            self?.driverPhone = driver?.user.phone
        })

        FirebaseHelper.shareInstance()?.checkBlockDirverInfo(book.info.driverFirebaseId, handler: { (fav) in
            if fav == nil {
                self.btnBlock?.isHidden = false
            } else {
                self.btnBlock?.isHidden = true
            }
        })
        var items = [String]()
        items.addOptional(book.info?.startAddress)
        book.info.wayPoints?.forEach({ (json) in
            guard let i = try? TripWayPoint.toModel(from: json) else {
                return
            }
            items.addOptional(i.address)
        })
        items.addOptional(book.info?.endAddress)
        let vInfo = InTripAddressInfoView(frame: .zero)
        vInfo >>> containerDirection >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        vInfo.setupDisplay(item: items)
        
        let bookPrice = book.info.getBookPrice()
        
        let promoVal = book.info.fareClientSupport + book.info.promotionValue
        self.lblPromotionValue?.text = "-\(self.formatPrice(promoVal))"
        
        if (bookPrice > 0) {
            let clientPay = max(bookPrice + book.info.additionPrice - promoVal, 0)
            self.lblTotalPrice?.text = self.formatPrice(clientPay)
        }
        
        self.lblFareValue?.text = self.formatPrice(bookPrice + book.info.additionPrice)
        
        if book.info.payment == PaymentMethodCash {
            self.lblPaymentBy?.text = Text.payWithCash.localizedText
        } else if book.info.payment == PaymentMethodVATOPay {
            self.lblPaymentBy?.text = Text.payWithVATOPay.localizedText
        } else {
            self.lblPaymentBy?.text = Text.payWithVisa.localizedText
        }
    }
    
    private func formatPrice(_ _priceNum: Int) -> String {
        let priceFormat = NumberFormatter()
        priceFormat.currencyCode = "VND"
        priceFormat.currencySymbol = ""
        priceFormat.numberStyle = .currency
        let number = NSNumber(value: _priceNum)
        let priceStr = priceFormat.string(from: number)
        return "\(priceStr ?? "")đ"
    }
    
    private func showRatingView() {
        let ratingView = FCEvaluteView()
        ratingView.booking = self.book
        ratingView.reloadData()
        self.navigationController?.view.addSubview(ratingView)
        ratingView.show()
        
    self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        ratingView.setActionCallback { [weak self] (index) in
            // 0: cancel, 1: done
            if index == 1 {
                /*
                 AlertVC.showAlertObjc(on: self, title: Text.notification.localizedText, message: Text.thankForUsingService.localizedText, actionOk:Text.backToMainPage.localizedText, actionCancel: nil, callbackOK: {
                 NotificationCenter.default.post(name: Notification.Name("kBotificationCompletedBook"), object: nil)
                 self?.dismissTripView()
                 }, callbackCancel: {
                 })
                 */
                NotificationCenter.default.post(name: Notification.Name("kBotificationCompletedBook"), object: nil)
                self?.dismissTripView()
            } else {
                NotificationCenter.default.post(name: Notification.Name("kBotificationCompletedBook"), object: nil)
                self?.dismissTripView()
            }
        }
    }
    
    private func dismissTripView() {
        UserDataHelper.shareInstance().removeLastestTripbook()
        self.dismiss(animated: true, completion: self.delegate?.dismissTrip)
//        self.delegate?.dismissTrip()
        //        if ([self.delegate respondsToSelector:@selector(onBookCanceled)]) {
        //            [self.delegate didCompleteTrip];
        //        }
//        self.presentingViewController?
//            .presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func blockDriver() {
        guard let driverFirebaseId = self.book?.info.driverFirebaseId else { return }
        FirebaseHelper.shareInstance()?.getDriver(driverFirebaseId, handler: { [weak self](driver) in
            let fav = FCFavorite()
            fav.userId = self?.book?.info.driverUserId ?? 0
            fav.isFavorite = false
            fav.userFirebaseId = driverFirebaseId
            fav.userName = driver?.user.fullName
            fav.userAvatar = driver?.user.avatarUrl
            fav.userPhone = driver?.user.phone
            
            FirebaseHelper.shareInstance()?.requestAdd(fav, withCompletionBlock: { (error, ref) in
                FCNotifyBannerView.banner()?.show(nil, for: .success, autoHide: true, message: "Đã thêm \(driver?.user.fullName ?? "") vào danh sách Danh sách chặn của bạn.", closeClick: nil, bannerClick: nil)
            })
        })
    }
}
