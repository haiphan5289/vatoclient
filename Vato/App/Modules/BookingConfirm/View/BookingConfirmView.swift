//  File name   : BookingConfirmView.swift
//
//  Author      : Dung Vu
//  Created date: 9/17/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RxSwift
import UIKit
import RxCocoa
import FwiCore
import SnapKit

extension PaymentMethod {
    var name: String {
        switch self {
        case PaymentMethodCash:
            return Text.cash.localizedText
        case PaymentMethodVATOPay:
            return Text.wallet.localizedText
        case PaymentMethodATM:
            return "ATM"
        case PaymentMethodVisa, PaymentMethodMastercard:
            return "Visa/MasterCard"
        default:
            return ""
        }
    }
    
    var bgColor: UIColor {
        switch self {
        case PaymentMethodCash:
            return Color.battleshipGreyTwo
        case PaymentMethodVATOPay:
            return Color.orange
        default:
            return Color.battleshipGreyTwo
        }
    }
}

class BookingConfirmView: UIView {
    /// Class's public properties.
    struct Config {
        static let napas = "Thẻ ***"
        static let heightOfCellSuggest: Float = 62
        static let numberCellDisplay = 2
    }
    
    @IBOutlet weak var header: BookingConfirmHeaderView?
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var backgroundView: UIView?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var btnConfirm: UIButton?
    @IBOutlet weak var lblLastPrice: UILabel?
    @IBOutlet weak var lblMoneyWallet: UILabel?
    @IBOutlet weak var paymentMethodsLabel: UILabel?
    @IBOutlet weak var lblChoosePaymentMethod: UILabel?
    @IBOutlet weak var btnChoosePaymentMethod: UIButton?
    @IBOutlet weak var btnMoveBackToCurrent: UIButton?
    @IBOutlet weak var btnDetailPrice: UIButton?
    
    @IBOutlet weak var heightOfViewSuggestService: NSLayoutConstraint?
    @IBOutlet weak var listSevericeTableView: UITableView?
    @IBOutlet weak var viewAllLbl: UILabel?
    @IBOutlet weak var chooseServiceLbl: UILabel?
    
    @IBOutlet weak var lblQuickBooking: UILabel?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var iconRightImageView: UIImageView?
    @IBOutlet var containerPayment: UIView?
    @IBOutlet var hContainerPayment: NSLayoutConstraint?
    
    private (set) lazy var alertView = self.createAlertView()
    private (set) var selectPaymentView: VatoPaymentSelectView?
    private lazy var mReadySetupPayment = PublishSubject<Void>()
    
    var readySetupPayment: Observable<Void> {
        return mReadySetupPayment
    }
    
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 8)
        v.containerColor = .white
        return v
    }()
    
    var tapPoint: CGPoint?
    
    var serviceSelected: ServiceCanUseProtocol? {
        didSet { didSelect(service: serviceSelected) }
    }
    
    var isFixedBook: Bool = true {
        didSet {
            guard isFixedBook != oldValue else {
                return
            }
            updatelayout()
        }
    }

    private(set) lazy var eSelectedServiceFavorite = PublishSubject<Bool>()
    private(set) lazy var eSelectedService = PublishSubject<ServiceCanUseProtocol>()
    private(set) lazy var listServiceSubject = BehaviorRelay<[ServiceCanUseProtocol]>(value: [])
    
    var promotion: PromotionModel? {
        didSet {
            updatePromotionInfor()
            reloadCellsVisible()
        }
    }
    var price: BookingConfirmPrice?
    var booking: Booking? {
        didSet { reloadCellsVisible() }
    }
    
    var paymentMethod = PaymentMethodCash
    var tip: Double = 0
    var eUserInfor: Observable<UserInfo>? {
        didSet {
            eUserInfor?.subscribe(onNext: { [weak self] infor in
                self?.myInfor = infor
            }).disposed(by: disposeBag)
        }
    }

    /// Class's private properties.
    var itemsView: [BookingConfirmItemView]? {
        return self.stackView?.arrangedSubviews.compactMap({ $0 as? BookingConfirmItemView })
    }

    private var myInfor: UserInfo?
    private(set) lazy var eAction: PublishSubject<BookingConfirmType> = PublishSubject()
    private(set) lazy var eUpdate: PublishSubject<BookingConfirmUpdateType> = PublishSubject()

    private (set) lazy var disposeBag = DisposeBag()
    
    func setupRX() {
        eUpdate.bind { [weak self] type in
            guard let wSelf = self else {
                return
            }
            
            defer {
                wSelf.recheckDetail()
            }
            
            switch type {
            case .service(let s):
                wSelf.header?.update(from: type)
                wSelf.serviceSelected = s
            case .updatePrice(let infor):
                wSelf.price = infor
                wSelf.btnConfirm?.isEnabled = (!wSelf.isFixedBook || infor.originalPrice > 0 ) //&& wSelf.myInfor != nil
                wSelf.updatePromotionInfor()
                //                let text = (infor.lastPrice + UInt32(infor.tip)).currency
            //                wSelf.lblLastPrice?.text = (infor.lastPrice + UInt32(infor.tip)).currency
            case .note(let string):
                let f = wSelf.itemsView?.first(where: { $0.type == .note })
                f?.update(from: BookingConfirmUpdateType.update(string: nil, exist: string?.isEmpty == false))
            case .updateTip(let tip):
                wSelf.tip = tip
                let f = wSelf.itemsView?.first(where: { $0.type == .addTip })
                let message = tip > 0 ? UInt32(tip).currency : nil
                f?.update(from: BookingConfirmUpdateType.update(string: message, exist: tip > 0))
                wSelf.updatePromotionInfor()
            case .updateMethod(let method):
                wSelf.lblMoneyWallet?.text = ""
                let name: String?
                defer {
                    wSelf.lblChoosePaymentMethod?.text = name
                }
                guard method.napas else {
                    name = method.type.method?.name
                    return
                }
                let last = method.name.suffix(4)
                name = Config.napas + "\(last)"
            case .updatePromotion(let model):
                self?.promotion = model
                let f = wSelf.itemsView?.first(where: { $0.type == .coupon })
                f?.update(from: BookingConfirmUpdateType.update(string: model?.code, exist: model != nil))
            case .book:
                wSelf.btnConfirm?.sendActions(for: .touchUpInside)
            case .updateListService(let listSevice):
                let old = wSelf.listServiceSubject.value
                
                guard let selectSeverice = listSevice.first,
                    old.contains(where: { $0.service.id == selectSeverice.service.id }) == false else {
                    return
                }
                wSelf.listServiceSubject.accept(listSevice)
            case .updateBooking(let booking):
                wSelf.booking = booking
            default:
                break
            }
            }.disposed(by: disposeBag)
        let detailPrice = self.btnDetailPrice?.rx.tap.map { BookingConfirmType.detailPrice }
        let choose = self.header?.btnAction?.rx.tap.map { BookingConfirmType.chooseInformation }
        let confirm = self.btnConfirm?.rx.tap.map { BookingConfirmType.booking }
        let wallet = self.btnChoosePaymentMethod?.rx.tap.map { BookingConfirmType.wallet }
        let moveBack = self.btnMoveBackToCurrent?.rx.tap.map { BookingConfirmType.moveToCurrent }
        
        Observable.merge([choose, confirm, wallet, moveBack, detailPrice].compactMap { $0 }).subscribe(eAction).disposed(by: disposeBag)
        
        setupRXListService()
    }
    
    deinit {
        printDebug("\(#function)")
    }
    
    func visualize() {
        // todo: Visualize view's here.
        self.btnConfirm?.applyButtonWithoutBackground(style: .default)
        self.btnConfirm?.setBackground(using: Color.orange, state: .normal)
        self.btnConfirm?.setBackground(using: #colorLiteral(red: 0.6588235294, green: 0.6588235294, blue: 0.6588235294, alpha: 1), state: .disabled)
        self.btnConfirm?.isEnabled = false

        let text1 = NSAttributedString(string: Text.fare.localizedText, attributes: [
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: .bold),
            NSAttributedString.Key.foregroundColor:UIColor.black
        ])
        let text2 = NSAttributedString(string: "\n\(Text.baseOnActualRoute.localizedText)", attributes: [
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12, weight: .regular),
            NSAttributedString.Key.foregroundColor:UIColor.black
        ])
        let text = NSMutableAttributedString(attributedString: text1)
        text.append(text2)
        lblQuickBooking?.attributedText = text

        self.paymentMethodsLabel?.text = Text.paymentMethod.localizedText
        
        containerView?.backgroundColor = .clear
        containerView?.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
}

// MARK: Class's public methods
extension BookingConfirmView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        visualize()
        registerCellSevice()
        setupRX()
    }

    func heightContainer() -> CGFloat {
        let s = self.containerView?.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return s?.height ?? 0
    }
    
    func showAlertPromotion(with type: BookingConfirmAlertPromotionType) {
        let show: Bool
        switch type {
        case .success:
            show = true
        default:
            show = false
        }
        self.updateStatusPromotion(canApply: show)
        alertView.showAlert(with: type)
    }
    
    private func createAlertView() -> BookingConfirmAlertPromotionView {
        let v = BookingConfirmAlertPromotionView(frame: .zero)
        v >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(95)
            })
        }
        return v
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func updatelayout() {
        lblTitle?.text = FwiLocale.localized("Tổng tiền thanh toán")
        self.chooseServiceLbl?.text = Text.chooseServices.localizedText
        self.viewAllLbl?.text = Text.seeAll.localizedText
        
        self.lblLastPrice?.isHidden = !self.isFixedBook
        self.btnDetailPrice?.isHidden = !self.isFixedBook
        self.lblQuickBooking?.isHidden = self.isFixedBook

        let text = self.isFixedBook ? Text.quickBooking.localizedText : Text.bookWithoutDestination.localizedText
        self.btnConfirm?.setTitle(text, for: .normal)

        if !(self.stackView?.arrangedSubviews.count == 0) {
            let arrangedSubviews = self.stackView?.arrangedSubviews
            arrangedSubviews?.forEach({
                self.stackView?.removeArrangedSubview($0)
                $0.removeFromSuperview()
            })
        }

        let source = self.isFixedBook ? BookingConfirmType.allCases : BookingConfirmType.quickBook
        let items = source.map({ type -> BookingConfirmItemView in
            let v = BookingConfirmItemView.createView(with: type)
            v.btnAction?.rx.tap.map { type }.subscribe(onNext: { [weak self] in
                self?.eAction.onNext($0)
            }).disposed(by: disposeBag)
            return v
        })

        items.last?.lineLeftView?.isHidden = true
        items.enumerated().forEach { e in
            self.stackView?.insertArrangedSubview(e.element, at: e.offset)
        }
    }
    
    func recheckDetail() {
        var isHaveValue: Bool = false
        
//        if tip > 0 {
//            isHaveValue = true
//        }
        
        if let promotion = promotion, promotion.canApply {
            isHaveValue = true
        }
        
        if let clientAmount = self.price?.clientAmount, clientAmount > 0 {
            isHaveValue = true
        }
        
        let att: NSAttributedString
        self.btnDetailPrice?.setAttributedTitle(nil, for: .normal)
        if isHaveValue {
            let text: String
            let f: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold)
            let color = Color.battleshipGreyTwo
            let v: CGFloat = 2
            
            let range = price?.service?.rangePrice
            let min = range?.min ?? 0
            let max = range?.max ?? 0
            if price?.service?.isGroupService == true,
                min != max {
                text = (min + UInt32(tip)).currency + "-" + (max + UInt32(tip)).currency
            } else {
                text = (min + UInt32(tip)).currency
            }
            att = text.attribute.add(attributes: [.font(f: f), .color(c: color), .strike(v: v)])
        } else {
            let f: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let color = Color.battleshipGreyTwo
            att = PromotionConfig.detailPrice.attribute.add(attributes: [.font(f: f), .color(c: color)])
        }
        
        self.btnDetailPrice?.setAttributedTitle(att, for: .normal)
    }

        func updatePromotionInfor() {
            let v = self.itemsView?.first(where: { $0.type == .coupon })
            v?.iconStatus?.isHidden = promotion == nil
            let tip = UInt32(price?.tip ?? 0)
            let discount = promotion?.discount ?? 0
            let minDiscount = promotion?.minDiscount ?? 0
            
            guard let service = self.price?.service else { return }
            let range = service.rangePrice
            let originalPrice = range?.min ?? 0
            let totalPrice = range?.max ?? 0
            
            let l1 = originalPrice + tip > discount ? originalPrice + tip - minDiscount : 0
            let l2 = totalPrice + tip > discount ? totalPrice + tip - discount : 0
            let lastOriginal = l1
            let lastTotal = l2
            
            if service.isGroupService,
                lastTotal != lastOriginal {
                self.lblLastPrice?.text = "\(lastOriginal.currency)-\(lastTotal.currency)"
            } else {
                self.lblLastPrice?.text = "\(lastTotal.currency)"
            }
        }
    
    func updateStatusPromotion(canApply success: Bool) {
        guard let v = self.itemsView?.first(where: { $0.type == .coupon }) else {
            return
        }
        v.iconStatus?.isHighlighted = success
        updatePromotionInfor()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        self.tapPoint = point
        guard let v = super.hitTest(point, with: event) else {
            return nil
        }

        guard (v is UIControl) || self.containerView?.frame.contains(point) == true else {
            return nil
        }
        return v
    }
}

extension BookingConfirmView {
    func updatePaymentStream(use stream: PaymentStream, controller: UIViewController?, type: SwitchPaymentType) {
        guard selectPaymentView == nil else {
            selectPaymentView?.reload(service: type)
            return
        }
        
        let vPayment = VatoPaymentSelectView.createPaymentView(use: stream, service: type)
        vPayment >>> containerPayment >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        vPayment.controller = controller
        vPayment.updateLayout.bind { [weak self](constant) in
            UIView.animate(withDuration: 0.3) {
                self?.hContainerPayment?.constant = constant
                self?.layoutIfNeeded()
            }
        }.disposed(by: disposeBag)
        vPayment.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), position: .top)
        self.selectPaymentView = vPayment
        mReadySetupPayment.onNext(())
    }
}

// MARK: Class's private methods
private extension BookingConfirmView {
    private func initialize() {
        updatelayout()
    }
}
