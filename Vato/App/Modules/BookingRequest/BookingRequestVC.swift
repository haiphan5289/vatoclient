//  File name   : BookingRequestVC.swift
//
//  Author      : Dung Vu
//  Created date: 1/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import SnapKit
import FwiCore
import FwiCoreRX

typealias DriverInforTuple = (driver: Driver?,firebaseID: String?)
protocol BookingRequestPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var eError: Observable<Error> { get }
    var eStatus: Observable<String> { get }
    var priceNew: Observable<String> { get }
    var eShowDriver: Observable<DriverInforTuple> { get }
    var bookingRequestStream: BookingRequestStream { get }
    func bookingRequestCancel()
    func moveToTrip()
    func beginBook()
}

final class BookingRequestVC: UIViewController, BookingRequestPresentable, BookingRequestViewControllable {
    
    public struct Config {
        struct Payment {
            static let vato = Text.wallet.localizedText
            static let money = Text.cash.localizedText
            static let napas = "Thẻ ***"
        }
        
        struct PayBill {
            static let noMoney = Text.calculateBaseOnActualMoving.localizedText
        }
        
        struct Cancel {
            static let title = Text.tripCancelled.localizedText.capitalized
            static let confirmTitle = Text.tripCancellationConfirm.localizedText
            static let message = Text.tripCancellationConfirmMessage.localizedText
            static let agree = Text.tripCancelled.localizedText
            static let notAgree = Text.ignore.localizedText
        }
        
        struct Time {
            static let timeEnableCancel = 15.0
        }
        
        struct Note {
            static let title = Text.noteForDriver.localizedText
        }
        
        struct Address {
            static let oneTouch = Text.destinationBaseOnYourRequest.localizedText
        }
        
        struct HeaderNote {
            static let begin = Text.findBestDriverForYou.localizedText
            static let contactDriver = "\(Text.contactDriver.localizedText) ..."
            static let driverNote = Text.driversAreReceivingYourBookingRequest.localizedText
        }
        
        struct HeaderDeliverNote {
            static let begin = Text.findBestDriverDeliveryForYou.localizedText
            static let contactDriver = "\(Text.contactDriver.localizedText) ..."
            static let driverNote = Text.driversDeliverAreReceivingYourBookingRequest.localizedText
        }
    }

    /// Class's public properties.
    weak var listener: BookingRequestPresentableListener?
    private lazy var mapView = GMSMapView()
    private (set)lazy var disposeBag = DisposeBag()
    private lazy var currentModelBook: BookingConfirmInformation? = self.listener?.bookingRequestStream.currentModelBook
    var containerView: UIView? {
        return mContainer
    }
    
    private var lblTitle: UILabel?
    private var btnCancel: UIButton?
    private var btnShowContainer: UIButton?
    private var descriptAddressView: DestinationInfoView?
    private var lblSubTitle: UILabel?
    private var sContainer: CGSize = .zero
    private var lblDescriptionPayment: UILabel?
    private (set) lazy var panGesture: UIPanGestureRecognizer? = {
        let panGesture = UIPanGestureRecognizer()
        containerView?.addGestureRecognizer(panGesture)
        return panGesture
    }()
    
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 7)
        v.containerColor = .white
        return v
    }()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        self.listener?.beginBook()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    private func setupMap() {
        mapView.isUserInteractionEnabled = false
        mapView >>> view >>> {
            $0.setMinZoom(MapConfig.Zoom.max, maxZoom: MapConfig.Zoom.max)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
    }
    
    deinit { printDebug("\(#function)") }
}

// MARK: View's event handlers
extension BookingRequestVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
}

// MARK: Class's private methods
private extension BookingRequestVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        setupMap()
        let deliveryMode = self.currentModelBook?.service?.service.serviceType == VatoServiceType.delivery
        
        //============
        // 1: Status
        let headerView = UIView.create {
            $0.backgroundColor = .clear
        }
        
        headerView.addSeperator()
        
        let vLine = UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0.8745098039, green: 0.8823529412, blue: 0.9019607843, alpha: 1)
            $0.cornerRadius = 1.5
            } >>> headerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(8)
                    make.centerX.equalToSuperview()
                    make.size.equalTo(CGSize(width: 34, height: 3))
                })
        }
        
        let lblTitle: UILabel = UILabel.create {
            $0.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.text = deliveryMode ? Config.HeaderDeliverNote.begin : Config.HeaderNote.begin
            } >>> headerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(vLine.snp.bottom).offset(12)
                    make.centerX.equalToSuperview()
                })
        }
        self.lblTitle = lblTitle
        
        let lblSubTitle: UILabel = UILabel.create {
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14)
//            $0.text = deliveryMode ? Config.HeaderDeliverNote.driverNote : Config.HeaderNote.driverNote
            } >>> headerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblTitle.snp.bottom).offset(0)
                    make.centerX.equalToSuperview()
                    make.bottom.equalTo(-12)
                })
        }
        self.lblSubTitle = lblSubTitle
        
        let btnShowContainer = UIButton.create { $0.setContentHuggingPriority(.defaultLow, for: .horizontal) }
        btnShowContainer >>> headerView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
        
        self.btnShowContainer = btnShowContainer
        //============
        let book = self.currentModelBook?.booking
        let start = book?.originAddress.subLocality
        let end = book?.destinationAddress1 != nil ? book?.destinationAddress1?.subLocality : Config.Address.oneTouch
        let a: [String?] = [start, end]
        
        //2: Address
        let descriptAddressView = DestinationInfoView(with: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), placeNames: a.compactMap { $0 })
        descriptAddressView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.descriptAddressView = descriptAddressView
        
        descriptAddressView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        //============
        // Payment
        let vPayment = UIView.create {
            $0.backgroundColor = .white
        }

//        vPayment.addSeperator()
        let lblTitlePayment = UILabel.create{
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14)
            } >>> vPayment >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(10)
                })
        }
        lblTitlePayment.text = Text.pay.localizedText
        
        let vPaymentType = UIView.create {
            $0.backgroundColor = Color.orange
            $0.cornerRadius = 10
        } >>> vPayment >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.height.equalTo(20)
                make.top.equalTo(lblTitlePayment).offset(20)
            })
        }
        
        let lblPaymentType = UILabel.create{
            $0.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 12)
            } >>> vPaymentType >>> {
                $0.setContentHuggingPriority(.required, for: .horizontal)
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(8)
                    make.right.equalTo(-8)
                    make.top.bottom.equalTo(0)
                })
        }
        
        func titlePayment() -> String? {
            guard let method = self.currentModelBook?.paymentMethod , let type = method.type.method  else {
                return nil
            }
            switch type {
            case PaymentMethodCash, PaymentMethodAll:
                return Config.Payment.money
            case PaymentMethodVATOPay:
                return Config.Payment.vato
            case PaymentMethodVisa, PaymentMethodMastercard, PaymentMethodATM:
                let last = method.number?.suffix(4)
                let m = Config.Payment.napas + "\(last.orNil(""))"
                return m
            case PaymentMethodMomo:
                return "Momo"
            case PaymentMethodZaloPay:
                return "ZaloPay"
            default:
                fatalError("Please Implement")
            }
        }
        
        func colorBgPayment() -> UIColor {
            guard let method = self.currentModelBook?.paymentMethod , let type = method.type.method  else {
                return Color.battleshipGreyTwo
            }
            switch type {
            case PaymentMethodCash, PaymentMethodAll:
                return Color.battleshipGreyTwo
            case PaymentMethodVATOPay:
                return Color.orange
            default:
                return Color.battleshipGreyTwo
            }
        }
        
        lblPaymentType.text = titlePayment()?.uppercased()
        vPaymentType.backgroundColor = colorBgPayment()
        
        let lblDescriptionPayment = UILabel.create {
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textAlignment = .right
            } >>> vPayment >>> {
                $0.snp.makeConstraints({ (make) in
                    make.right.equalTo(-16)
                    make.top.equalTo(16.5)
                    make.bottom.equalTo(-16.5)
                    make.left.equalTo(lblTitlePayment.snp.right).offset(5).priority(.high)
                })
        }
        self.lblDescriptionPayment = lblDescriptionPayment
        
        func updatePriceTitle() {
            guard let tripType = book?.tripType else {
                return
            }
            
            switch tripType {
            case BookService.fixed:
                lblDescriptionPayment.numberOfLines = 1
                lblDescriptionPayment.font = UIFont.systemFont(ofSize: 20, weight: .medium)
                // Recalculate
                var discount: UInt32 = 0
                var minDiscount: UInt32 = 0
                if self.currentModelBook?.promotionModel?.canApply == true {
                    discount = self.currentModelBook?.promotionModel?.discount ?? 0
                    minDiscount = self.currentModelBook?.promotionModel?.minDiscount ?? 0
                }
                let priceInformation = self.currentModelBook?.informationPrice
                let tip = UInt32(priceInformation?.tip ?? 0)
                
                if let service = priceInformation?.service {
                    let range = service.rangePrice
                    let originalPrice = range?.min ?? 0
                    let totalPrice = range?.max ?? 0
                    
                    let l1 = originalPrice + tip > discount ? originalPrice + tip - minDiscount : 0
                    let l2 = totalPrice + tip > discount ? totalPrice + tip - discount : 0
                    let lastOriginal = l1
                    let lastTotal = l2
                    if service.isGroupService,
                        lastTotal != lastOriginal {
                        lblDescriptionPayment.text = "\(lastOriginal.currency)-\(lastTotal.currency)"
                    } else {
                        lblDescriptionPayment.text = "\(lastTotal.currency)"
                    }
                }
            default:
                lblDescriptionPayment.textAlignment = .left
                lblDescriptionPayment.numberOfLines = 2
                lblDescriptionPayment.text = Config.PayBill.noMoney
            }
        }
        
        updatePriceTitle()
        
        //============
        //
        let vCancel = UIView.create {
            $0.backgroundColor = .white
        }
        let textCancel = deliveryMode ? Text.deliveryCancel.localizedText : Config.Cancel.title
        let btnCancel = UIButton.create {
            $0.applyButton(style: .cancel)
            $0.setTitleColor(.gray, for: .disabled)
            $0.setTitle(textCancel, for: .normal)
            } >>> vCancel >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(12.5)
                    make.bottom.equalTo(-12.5)
                    make.right.equalTo(-16).priority(.high)
                    make.left.equalTo(16)
                    make.height.equalTo(40)
                })
        }
        
        self.btnCancel = btnCancel
        
        let views: [UIView]
        
        if let note = self.currentModelBook?.note, !note.isEmpty {
            let nView = UIView.create {
                $0.backgroundColor = .white
            }
            
            let lblTitleNote = UILabel.create {
                $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 14)
                $0.text = Config.Note.title
                } >>> nView >>> {
                    $0.snp.makeConstraints({ (make) in
                        make.left.equalTo(16)
                        make.top.equalTo(16)
                    })
            }
            
            UILabel.create {
                $0.textColor = .black
                $0.font = UIFont.systemFont(ofSize: 16)
                $0.text = note
                $0.numberOfLines = 2
                } >>> nView >>> {
                    $0.snp.makeConstraints({ (make) in
                        make.top.equalTo(lblTitleNote.snp.bottom).offset(8)
                        make.left.equalTo(lblTitleNote.snp.left)
                        make.width.equalTo(view.bounds.width - 32)
                        make.bottom.equalTo(-16)
                    })
            }
            
            nView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            views = [headerView, descriptAddressView, nView, vPayment, vCancel]
        } else {
            views = [headerView, descriptAddressView, vPayment, vCancel]
        }
        
        //============
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        
        stackView >>> mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        mContainer >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
        mContainer.dropShadow()
        
        //============
        let s = mContainer.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: CGFloat.infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        sContainer = s
//        self.dismiss()
        // Add view gradient
        let vG = BookingConfirmGradientView.init(frame: .zero)
        vG.colors = [UIColor(white: 1, alpha: 0).cgColor,UIColor(white: 1, alpha: 0.6).cgColor, UIColor(white: 1, alpha: 0.8).cgColor, UIColor.white.cgColor]
        view.insertSubview(vG, at: 1)
        vG >>> {
            $0.snp.makeConstraints({ (make) in
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(s.height)
            })
        }
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: s.height, right: 0)
        
    }
    
    private func addWaveView() {
        let wView = WaveView.init(frame: .zero)
        let s = CGSize(width: 250, height: 250)
        let visiable = view.bounds.height - sContainer.height
        let top = (visiable - s.height) / 2
        wView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(s)
                make.centerX.equalToSuperview()
                make.top.equalTo(top)
            })
        }
        
        let image = UIImage(named: "ic_origin_marker")
        let imgView = UIImageView(image: image)
        imgView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.centerX.equalTo(wView.snp.centerX).priority(.high)
                make.centerY.equalTo(wView.snp.centerY).offset(-(image?.size.height ?? 4) / 3).priority(.high)
            })
        }
        imgView.transform = CGAffineTransform(translationX: 0, y: -5)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .autoreverse, .repeat], animations: { [weak imgView] in
            imgView?.transform = .identity
        }, completion: nil)
    }
    
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.btnCancel?.isEnabled = false
        Observable<Int>.interval(Config.Time.timeEnableCancel, scheduler: MainScheduler.asyncInstance).take(1).bind { [weak self](_) in
            self?.btnCancel?.isEnabled = true
        }.disposed(by: disposeBag)
        
//        setupDraggable()
        
        self.btnCancel?.rx.tap.bind { [unowned self](_) in
            self.alertCancelBook()
        }.disposed(by: disposeBag)
        
//        self.btnShowContainer?.rx.tap.bind { [unowned self](_) in
//            self.showContainer()
//        }.disposed(by: disposeBag)
        
        self.rx.methodInvoked(#selector(self.viewWillAppear(_:))).take(1)
            .observeOn(MainScheduler.asyncInstance)
            .bind
        { [unowned self](_) in
            guard let book = self.currentModelBook, let start = book.booking?.originAddress else {
                return
            }
            
            self.mapView.animate(with: GMSCameraUpdate.setTarget(start.coordinate, zoom: MapConfig.Zoom.max))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: self.addWaveView)
        }.disposed(by: disposeBag)
        
        self.listener?.eError.subscribe(onNext: { [weak self] in
            self?.handler(error: $0)
        }).disposed(by: disposeBag)
        
        self.listener?.eStatus.subscribe(onNext: { [weak self](status) in
            self?.lblTitle?.text = status
        }).disposed(by: disposeBag)
        
        self.listener?.priceNew.subscribe(onNext: { [weak self](prices) in
            self?.lblDescriptionPayment?.text = prices
        }).disposed(by: disposeBag)
        
        self.listener?.eShowDriver.subscribe(onNext: { [weak self](infor) in
            guard let wSelf = self else { return }
            wSelf.showInformationDriver(from: infor)
        }).disposed(by: disposeBag)
    }
    
    private func showInformationDriver(from infor: DriverInforTuple) {
        let run: () -> () = { [weak self] in
//            guard let wSelf = self else { return }
//            AlertFoundDriverVC
//                .show(on: wSelf, firebaseId: infor.firebaseID, driver: infor.driver)
//                .delay(0.3, scheduler: MainScheduler.asyncInstance)
//                .bind { [weak self] in
                    self?.listener?.moveToTrip()
//            }.disposed(by: wSelf.disposeBag)
        }
    
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: false, completion: run)
        } else { run() }
    }
    
    private func alertCancelBook() {
        let alertOK = AlertAction.init(style: .default, title: Config.Cancel.agree, handler: { [weak self] in
            self?.listener?.bookingRequestCancel()
        })
        let alertCancel = AlertAction.init(style: .cancel, title: Config.Cancel.notAgree, handler: {})

        AlertVC.show(on: self, title: Config.Cancel.confirmTitle, message: Config.Cancel.message, from: [alertCancel, alertOK], orderType: .horizontal)
    }
    
    private func handler(error: Error) {
        let message: String
        let mButton: String
        let title: String
        if let e = error as? BookingError {
            switch e {
            case .noDriver:
                title = Text.bookingFeedback.localizedText
                message = Text.allDriversAreBusy.localizedText
                mButton = Text.returnToBookingConfirm.localizedText
                UserDataHelper.shareInstance().removeLastestTripbook()
            case .noDriverAccept:
                title = Text.bookingFeedback.localizedText
                message = Text.noDriversAcceptedBookingRequests.localizedText
                mButton = Text.returnToBookingConfirm.localizedText
                UserDataHelper.shareInstance().removeLastestTripbook()
            case .clientCantBook:
                title = Text.notification.localizedText
                message = Text.cannotContinueWithBookingRequest.localizedText
                mButton = Text.dismiss.localizedText
                UserDataHelper.shareInstance().removeLastestTripbook()
            case .noNetwork:
                title = Text.networkDown.localizedText
                message = Text.networkDownDescription.localizedText
                mButton = Text.agree.localizedText
            case .other(let e):
                title = Text.bookingFeedback.localizedText
                message = e.localizedDescription
                mButton = Text.agree.localizedText
            case .errorRequestDriver:
                title = ""
                message = Text.errorRequestTimout.localizedText
                mButton = Text.dismiss.localizedText
            default:
                title = Text.notification.localizedText
                message = Text.cannotContinueWithBookingRequest.localizedText
                mButton = Text.dismiss.localizedText
            }
        } else {
            title = Text.notification.localizedText
            message = Text.cannotContinueWithBookingRequest.localizedText
            mButton = Text.dismiss.localizedText
        }
        let action = AlertAction.init(style: .default, title: mButton, handler: { [weak self] in
            self?.listener?.bookingRequestCancel()
        })
        
        let run: () -> () = { [weak self] in
            AlertVC.show(on: self, title: title, message: message, from: [action], orderType: .horizontal)
        }
        
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: false, completion: run)
        } else { run() }
    }
}

extension BookingRequestVC { //: DraggableViewProtocol {
    func showContainer() {
        guard self.containerView?.transform == .identity  else {
            self.containerView?.transform = .identity
            return
        }
        self.dismiss()
    }
    
    func dismiss() {
        let h = sContainer.height - 65.33
        self.containerView?.transform = CGAffineTransform(translationX: 0, y: h)
    }
    
    func clearWindows() -> Observable<Void> {
        return Observable.create { [unowned self](s) -> Disposable in
            let next: () -> () = {
                s.onNext(())
                s.onCompleted()
            }
            
            if self.presentedViewController != nil {
                self.dismiss(animated: true, completion: next)
            } else {
                next()
            }
            return Disposables.create()
        }
    }
}
