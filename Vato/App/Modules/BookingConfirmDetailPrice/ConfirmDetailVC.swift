//  File name   : ConfirmDetailVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import FwiCoreRX

enum FromService {
    case booking
    case delivery
}

protocol ConfirmDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var priceUpdate: PriceStream { get }
    var transportStream: TransportStream { get }
    var promotionStream: PromotionStream { get }
    func closeDetail()
    func detailBook()
}

final class ConfirmDetailVC: UIViewController, ConfirmDetailPresentable, ConfirmDetailViewControllable {
    /// Class's public properties.
    weak var listener: ConfirmDetailPresentableListener?

    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var panGesture: UIPanGestureRecognizer?

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var tipLabel: UILabel?
    @IBOutlet weak var promotionLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?

    @IBOutlet weak var lblServiceName: UILabel?
    @IBOutlet weak var lblOriginalPrice: UILabel?
    @IBOutlet weak var lblTip: UILabel?
    @IBOutlet weak var lblDiscount: UILabel?
    @IBOutlet weak var lblTotal: UILabel?
    @IBOutlet weak var btnConfirm: UIButton?

    private var promotionModel: PromotionModel?
    
    private var serviceType: FromService = .booking
    
    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, fromService service: FromService) {
        self.serviceType = service
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView?.transform = CGAffineTransform.identity
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }

        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.dismiss()
    }

    /// Class's private properties.
    private(set) var disposeBag = DisposeBag()
}

// MARK: Class's public methods
extension ConfirmDetailVC {}

// MARK: Class's private methods
private extension ConfirmDetailVC {
    private func localize() {
        titleLabel?.text = Text.detailPrice.localizedText
//        tipLabel?.text = Text.tipDriver.localizedText
        tipLabel?.text = Text.serviceMore.localizedText
        promotionLabel?.text = Text.promotion.localizedText
        totalLabel?.text = Text.total.localizedText

        if serviceType == .delivery {
            btnConfirm?.setTitle(Text.confirmDelivery.localizedText, for: .normal)
        } else {
            btnConfirm?.setTitle(Text.quickBooking.localizedText, for: .normal)
        }
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        self.containerView?.transform = CGAffineTransform(translationX: 0, y: 1000)
        self.btnConfirm?.apply(style: .default)
    }

    private func setupRX() {
        // todo: Bind data to UI here.
        self.listener?.promotionStream.ePromotion.subscribe(onNext: { [weak self] m in
            self?.promotionModel = m
        }).disposed(by: disposeBag)

        self.listener?.priceUpdate.price.filterNil().subscribe(onNext: { [weak self] price in
            self?.lblTip?.text = price.tip.currency
            let promotion = self?.promotionModel?.discount ?? 0
            let discount = min(promotion + price.clientAmount, price.originalPrice)
            let minPromotion = self?.promotionModel?.minDiscount ?? 0
            let minDiscount = min(minPromotion + price.clientAmount, price.service?.rangePrice?.max ?? 0)
            self?.lblDiscount?.text = self?.showTextDiscount(discount: discount, minDiscount: minDiscount)
            
            
            let range = price.service?.rangePrice
            let original = range?.min ?? 0
            let total = range?.max ?? 0
            if price.service?.isGroupService == true,
                original != total {
                let tip = UInt32(price.tip)
                let lastOriginal = (original > promotion ? original - minPromotion : 0) + tip
                let lastTotal = (total > promotion ? total - promotion : 0) + tip
                self?.lblOriginalPrice?.text = "\(original.currency)-\(total.currency)"
                self?.lblTotal?.text = "\(lastOriginal.currency)-\(lastTotal.currency)"
            } else {
                self?.lblOriginalPrice?.text = original.currency
                let lastDisplay = price.lastPrice > promotion ? price.lastPrice - promotion : 0
                self?.lblTotal?.text = (lastDisplay + UInt32(price.tip)).currency
            }
            
        }).disposed(by: disposeBag)

        self.listener?.transportStream.selectedService.subscribe(onNext: { [weak self] s in
            self?.lblServiceName?.text = s.name
        }).disposed(by: disposeBag)

        self.btnConfirm?.rx.tap.bind { [weak self] in
            self?.listener?.detailBook()
        }.disposed(by: disposeBag)

        setupDraggable()
    }
    private func showTextDiscount(discount: UInt32, minDiscount: UInt32) -> String {
        guard discount > 0 else {
            return 0.currency
        }
        
        guard discount != minDiscount else {
            return discount.currency
        }
        
        return "-\(minDiscount.currency)-\(discount.currency)"
        
    }

}

extension ConfirmDetailVC: DraggableViewProtocol {
    func dismiss() {
        self.listener?.closeDetail()
    }
}
