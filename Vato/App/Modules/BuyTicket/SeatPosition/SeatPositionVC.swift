//  File name   : SeatPositionVC.swift
//
//  Author      : vato.
//  Created date: 10/8/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import SnapKit
import RxSwift
import FwiCore
import Atributika

import FwiCoreRX

protocol SeatPositionPresentableListener: class {
    var listDataObservable: Observable<[[[SeatModel?]]]>  { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var error: Observable<BuyTicketPaymenState> { get }
    var streamType: BuslineStreamType { get }
    var wayId: Int { get }
    var selectedSeats: Observable<[SeatModel]?> { get }
    var isDiscountTicket: Observable<Bool>  { get }
    
    func getListSeat(with routeId: Int?, carBookingId: Int?, kind: String?, departureDate: String?, departureTime: String?)
    func moveNext(with seats: [SeatModel], totalPrice: Double)
    func moveBack()
}

final class SeatPositionVC: UIViewController, SeatPositionPresentable, SeatPositionViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        enum FloorType {
            case down
            case up
        }
    }
    
    /// Class's public properties.
    weak var listener: SeatPositionPresentableListener?
    var seatParam: ChooseSeatParam!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnGround: UIButton!
    @IBOutlet weak var btnFloor: UIButton!
    @IBOutlet weak var heighFloorButton: NSLayoutConstraint!
    @IBOutlet weak var lblNumSeat: UILabel!
    @IBOutlet weak var lblSeat: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var lbPromotion: UILabel!
    @IBOutlet weak var lbPricePromotion: UILabel!
    @IBOutlet weak var lbLastPrice: UILabel!
    @IBOutlet weak var lbLastPriceValue: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var seatOldView: UIView!
    @IBOutlet weak var lblNumSeatOld: UILabel!
    @IBOutlet weak var lblSeatOld: UILabel!
    
    @IBOutlet weak var lblActiveSeat: UILabel!
    @IBOutlet weak var lblChoosingSeat: UILabel!
    @IBOutlet weak var lblSeatNone: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    private var loading: Bool = false
    @IBOutlet weak var stackViewPayment: UIStackView!
    @IBOutlet weak var stackViewPaymentSeats: UIStackView!
    @IBOutlet weak var viewDiscount: UIView!
    @IBOutlet weak var hViewPayment: NSLayoutConstraint!
    private var lbSeat: String = ""
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        
        self.listener?.getListSeat(with: self.seatParam.routeId,
                                        carBookingId: self.seatParam.carBookingId,
                                        kind: self.seatParam.kind,
                                        departureDate: self.seatParam.departureDate,
                                        departureTime: self.seatParam.departureTime)
        if self.seatParam.kind == "Giường" {
            lblNumSeat.text = String(format: Text.selectedBedsCount.localizedText, chooseSeats.count)
            lblNumSeatOld.text = Text.previousSelectedBed.localizedText
        } else {
            lblNumSeat.text = String(format: Text.selectSeatsCount.localizedText, chooseSeats.count)
            lblNumSeatOld.text = Text.previousSelectedSeat.localizedText
        }
        
        let removeSeatOldViewBlock:() -> Void = {
            self.stackView.removeArrangedSubview(self.seatOldView)
            self.seatOldView.removeFromSuperview()
            self.stackView.layoutIfNeeded()
        }
        
        let streamType = listener?.streamType ?? BuslineStreamType.buyNewticket
        switch streamType {
        case .changeTicket(let model):
            lblSeatOld.text = model.seatsStr()
            if model.wayId != listener?.wayId {
                removeSeatOldViewBlock()
            }
        case .buyNewticket, .roundTrip:
            removeSeatOldViewBlock()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        setupNavigation()
    }

    /// Class's private properties.
    lazy var disposeBag = DisposeBag()
    private var arrayViewController: [ChooseSeatViewController] = []
    private var pageViewC: UIPageViewController?
    private var chooseSeats: [SeatModel] = []
    private var dataSource: [[[SeatModel?]]] = []
    private lazy var noItemView : NoItemView = {
        let noItem = NoItemView(imageName: "empty",
                                message: Text.donotHaveSeats.localizedText,
                                on: self.containerView)
        noItem.lblMessage?.font = UIFont.systemFont(ofSize: 15)
        noItem.lblMessage?.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        return noItem
    }()
    
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 9)
        v.containerColor = .white
        return v
    }()
    private var viewDetailPrice: DetailPriceView = DetailPriceView(frame: .zero)
    private var textPriceFee: NSAttributedString = NSAttributedString()
    @IBOutlet weak var viewBottom: UIView!
}

// MARK: View's event handlers
extension SeatPositionVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension SeatPositionVC {
    func showAlertErrorReChooseSeat(with message: String) {
        let alertController = UIAlertController(title: Text.notification.localizedText, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Text.dismiss.localizedText, style: .destructive) { [weak self] (_) in
            guard let wSelf = self else { return }
            wSelf.chooseSeats.removeAll()
            wSelf.btnNext.setBackground(using: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1), state: .normal)
            wSelf.listener?.getListSeat(with: wSelf.seatParam.routeId,
                                        carBookingId: wSelf.seatParam.carBookingId,
                                        kind: wSelf.seatParam.kind,
                                        departureDate: wSelf.seatParam.departureDate,
                                        departureTime: wSelf.seatParam.departureTime)
        }
        
        action.setValue(Color.orange, forKey: "titleTextColor")
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showCheckShowEmtyView() {
        self.dataSource.count > 0 ? noItemView.detach() : noItemView.attach()
    }
}

// MARK: Class's private methods
private extension SeatPositionVC {
    private func localize() {
        
        
        self.lblTitle.text = "\(Text.choose.localizedText) \(FwiLocale.localized(self.seatParam.kind.lowercased()))"
        btnGround.setTitle(Text.floor1.localizedText.uppercased(), for: .normal)
        btnFloor.setTitle(Text.floor2.localizedText.uppercased(), for: .normal)
        btnNext.setTitle(Text.continue.localizedText, for: .normal)
        lblTotal.text = Text.totalAmount.localizedText
        lbPromotion.text = Text.promotion.localizedText
        lbLastPrice.text = Text.totalAmount.localizedText
        
        lblSeatNone.text = Text.empty.localizedText
        lblActiveSeat.text = Text.selectedBeds.localizedText
        lblChoosingSeat.text = Text.selectingBeds.localizedText
    }
    
    private func visualize() {
        
        viewInfo.backgroundColor = .clear
        viewInfo.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        let s = viewDetailPrice.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        viewDetailPrice >>> viewBottom >>> {
            $0.frame.size = s
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(16)
                make.top.equalToSuperview()
                make.bottom.equalTo(stackViewPaymentSeats.snp.top).inset(-16)
                if (self.seatParam.promotion?.value) != nil {
                    make.height.equalTo(170)
                    self.hViewPayment.constant = 170
                } else {
                    make.height.equalTo(105)
                    self.hViewPayment.constant = 105
                }
            }
            
        }
        
    }
    
    private func createPageViewController(with numberFloor: Int) {
        pageViewC = children.compactMap { $0 as? UIPageViewController }.first
        
        if numberFloor == 0 { return }
        
        let storyboard = UIStoryboard(name: "SeatPosition", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseSeatViewController") as? ChooseSeatViewController {
            (0..<numberFloor).forEach { _ in
                vc.listener = self
                arrayViewController.append(vc)
            }
        } else {
            //add noitem view
        }
        
        DispatchQueue.main.async {
            self.moveToFloor(with: Config.FloorType.down)
        }
    }
    
    private func setupRX() {
        if let listener = self.listener {
            Observable.combineLatest(listener.listDataObservable, listener.selectedSeats).bind {[weak self] (array, selectedSeats) in
                self?.didSelect(seats: selectedSeats ?? [])
                self?.dataSource = array
                
                let numFloor = array.count
                self?.createPageViewController(with: numFloor)
                if numFloor > 1 {
                    self?.heighFloorButton.constant = 49
                }
            }.disposed(by: disposeBag)
        }
        
//        listener?.listDataObservable.subscribe(onNext: { [weak self] (array) in
//            self?.dataSource = array
//            let numFloor = array.count
//            self?.createPageViewController(with: numFloor)
//            if numFloor > 1 {
//                self?.heighFloorButton.constant = 49
//            }
//        }).disposed(by: disposeBag)
        
        btnNext.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let wSelf = self, wSelf.chooseSeats.count > 0,
                self?.loading == false else { return }
            let totalPrice = Double(wSelf.chooseSeats.count) * wSelf.seatParam.pricePerTicket
            wSelf.listener?.moveNext(with: wSelf.chooseSeats, totalPrice: totalPrice)
        }).disposed(by: disposeBag)
        
        btnGround.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.moveToFloor(with: Config.FloorType.down)
        }).disposed(by: disposeBag)
        
        btnFloor.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.moveToFloor(with: Config.FloorType.up)
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        listener?.error.bind(onNext: {[weak self] (errorType) in
            AlertVC.showError(for: self, message: errorType.getMsg())
        }).disposed(by: disposeBag)
    }
    
    private func moveToFloor(with floor: Config.FloorType) {
        if floor == .down {
            btnGround.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.1333333333, alpha: 1), for: .normal)
            btnGround.setImage(UIImage(named: "ic_downstairs_on"), for: .normal)
            
            btnFloor.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1), for: .normal)
            btnFloor.setImage(UIImage(named: "ic_upstairs_off"), for: .normal)
            
            UIView.animate(withDuration: 0.3) {
                self.viewIndicator?.transform = CGAffineTransform(translationX: 0 , y: 0)
            }
            
            if let firstVC = self.arrayViewController.first {
                firstVC.arraySelected = self.chooseSeats
                firstVC.dataSource = self.dataSource.first?.filter{ !$0.isEmpty } ?? []
                self.pageViewC?.setViewControllers([firstVC], direction: .reverse, animated: true, completion: nil)
            }
        } else {
            btnGround.setTitleColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1), for: .normal)
            btnGround.setImage(UIImage(named: "ic_downstairs_off"), for: .normal)
            
            btnFloor.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.1333333333, alpha: 1), for: .normal)
            btnFloor.setImage(UIImage(named: "ic_upstairs_on"), for: .normal)
            
            let deltaX = UIScreen.main.bounds.width / 2
            UIView.animate(withDuration: 0.3) {
                self.viewIndicator?.transform = CGAffineTransform(translationX: deltaX , y: 0)
            }
            
            if let lastVC = self.arrayViewController.last {
                lastVC.arraySelected = self.chooseSeats
                lastVC.dataSource = self.dataSource.last?.filter{ !$0.isEmpty } ?? []
                self.pageViewC?.setViewControllers([lastVC], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    private func setupNavigation() {
//        let navigationBar = self.navigationController?.navigationBar
//        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
//        navigationBar?.setBackgroundImage(bgImage, for: .default)
//        navigationBar?.isTranslucent = false
//        navigationBar?.tintColor = .white
//        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
//        let image = UIImage(named: "ic_arrow_back")
//        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
//        leftButton.setImage(image, for: .normal)
//        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
//        let leftBarButton = UIBarButtonItem(customView: leftButton)
//        navigationItem.leftBarButtonItem = leftBarButton
//        leftButton.rx.tap.bind(onNext: weakify { wSelf in
//            wSelf.listener?.moveBack()
//        }).disposed(by: disposeBag)
//
        
        self.btnClose.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
        
    }

}

extension SeatPositionVC: ChooseSeatViewControllerListener {
    func didSelect(seats: [SeatModel]) {
        
        chooseSeats = seats
        if chooseSeats.count > 0 {
            self.btnNext.setBackground(using: #colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.1333333333, alpha: 1), state: .normal)
        } else {
            self.btnNext.setBackground(using: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1), state: .normal)
        }
        
        if self.seatParam.kind == "Giường" {
            lblNumSeat.text = String(format: Text.selectedBedsCount.localizedText, chooseSeats.count)
        } else {
            lblNumSeat.text = String(format: Text.selectSeatsCount.localizedText, chooseSeats.count)
        }
    
        let chooseSeatsStr = chooseSeats.compactMap { $0.chair }
        lblSeat.text = chooseSeatsStr.joined(separator: ", ")
        
        let price = Double(chooseSeats.count) * self.seatParam.pricePerTicket
        lblTotalValue.text = "\(price.currency)"
        
        if self.seatParam.promotion?.value != nil, self.seatParam.finalPrice != nil {
            let finalPrice = seats.reduce(0) { (x, y) -> Double in
                return x + (y.price ?? 0)
            }
            self.setupDetailPriceView(strSeats: chooseSeatsStr.joined(separator: ", "),
                                      totalPrice: price,
                                      finalPrice: finalPrice)
        } else {
            lbLastPriceValue.text = "\(price.currency)"
            self.setupDetailPriceView(strSeats: chooseSeatsStr.joined(separator: ", "),
                                      totalPrice: price,
                                      finalPrice: -1)
        }
    }
    func setupDetailPriceView(strSeats: String, totalPrice: Double, finalPrice: Double) {
        var lbSeats = strSeats
        if strSeats == "" {
            lbSeats = "  "
        } else {
            lbSeats = strSeats
        }
        var styles = [PriceInfoDisplayStyle]()
        let allTitle = Atributika.Style.font(.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
        let allPrice = Atributika.Style.font(.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
        let lastPrice = Atributika.Style.font(.systemFont(ofSize: 20, weight: .medium)).foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
        let discountPrice = Atributika.Style.font(.systemFont(ofSize: 15, weight: .medium)).foregroundColor(#colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.1333333333, alpha: 1))
        
        let seats = FwiLocale.localized(Text.seatSelected.localizedText).styleAll(allTitle).attributedString
        let textPriceFee = lbSeats.styleAll(allPrice).attributedString

        let styleSeats = PriceInfoDisplayStyle(attributeTitle: seats,
                                               attributePrice: textPriceFee,
                                               showLine: false,
                                               edge: .zero)
        styles.append(styleSeats)
        
        if finalPrice >= 0 {
            let lbMoney = FwiLocale.localized(Text.priceTicket.localizedText).styleAll(allTitle).attributedString
            let textMoney = totalPrice.currency.styleAll(allPrice).attributedString

            let styleMoney = PriceInfoDisplayStyle(attributeTitle: lbMoney,
                                                        attributePrice: textMoney,
                                                        showLine: false,
                                                        edge: .zero)
            styles.append(styleMoney)
            
            let lbDiscount = FwiLocale.localized(Text.discountTicketSeat.localizedText).styleAll(allTitle).attributedString
            let discountPromotion = max((totalPrice - finalPrice), 0)
            let textDiscount = ((finalPrice) >= 0 ? (0 - discountPromotion) : 0 ).currency.styleAll(discountPrice).attributedString

            let styleDiscount = PriceInfoDisplayStyle(attributeTitle: lbDiscount,
                                                        attributePrice: textDiscount,
                                                        showLine: false,
                                                        edge: .zero)
            styles.append(styleDiscount)
        }
        
        let totalLastPrice = (finalPrice >= 0) ? (finalPrice) : totalPrice
        let lbTotalPrice = FwiLocale.localized(Text.finalPriceTicketSeats.localizedText).styleAll(allTitle).attributedString
        let textTotalPrice = totalLastPrice.currency.styleAll(lastPrice).attributedString

        let styleTotalPrice = PriceInfoDisplayStyle(attributeTitle: lbTotalPrice,
                                                    attributePrice: textTotalPrice,
                                                    showLine: false,
                                                    edge: .zero)
        styles.append(styleTotalPrice)
        
        
        viewDetailPrice.setupDisplay(item: styles)
        
    }
}
