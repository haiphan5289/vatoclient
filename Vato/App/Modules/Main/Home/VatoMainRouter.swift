//  File name   : VatoMainRouter.swift
//
//  Author      : Dung Vu
//  Created date: 8/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import AVKit
import RxSwift
import RxCocoa

protocol VatoMainInteractable: Interactable, ScanQRListener, LatePaymentListener, SetLocationListener, InTripListener {
    var router: VatoMainRouting? { get set }
    var listener: VatoMainListener? { get set }
    
    func reloadBalance()
    func newTrip()
}

protocol VatoMainViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class VatoMainRouter: ViewableRouter<VatoMainInteractable, VatoMainViewControllable> {
    /// Class's constructor.
    init(interactor: VatoMainInteractable,
         viewController: VatoMainViewControllable,
         scanQRBuildable: ScanQRBuildable,
         latePaymentBuildable: LatePaymentBuildable,
         setLocationBuildable: SetLocationBuildable,
         inTripBuildable: InTripBuildable)
    {
        self.inTripBuildable = inTripBuildable
        self.latePaymentBuilder = latePaymentBuildable
        self.scanQRBuildable = scanQRBuildable
        self.setLocationBuildable = setLocationBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    
    /// Class's private properties.
    private lazy var handlerTrip: BookingConfirmHandlerIntrip = BookingConfirmHandlerIntrip()
    private let scanQRBuildable: ScanQRBuildable
    private let latePaymentBuilder: LatePaymentBuildable
    private let setLocationBuildable: SetLocationBuildable
    private let inTripBuildable: InTripBuildable
}

// MARK: VatoMainRouting's members
extension VatoMainRouter: VatoMainRouting {
    func routeToSetLocation() {
        let route = setLocationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func beginLastTrip(info: [String : Any], history: Bool) {
        let controller = TripMapsViewController()
        controller.bookSnapshot = info
        controller.fromHistory = history
        controller.delegate = handlerTrip
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
        self.viewController.uiviewController.tabBarController?.present(controller, animated: true, completion: nil)
    }
    
    func routeToTopup(use config: [TopupLinkConfigureProtocol], paymentStream: MutablePaymentStream?) {
        let topupVC = TopUpChooseVC(with: config, paymentStream: paymentStream)
        topupVC.listener = self
        let controller = FacecarNavigationViewController(rootViewController: topupVC)
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen

        self.viewController.uiviewController.tabBarController?.present(controller, animated: true, completion: nil)
    }
    
    private func requestPermissonCamera() -> Observable<Void> {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return Observable.just(())
        case .notDetermined:
            return Observable.create({ (s) -> Disposable in
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (grant) in
                    if grant {
                      s.onNext(())
                      s.onCompleted()
                    } else {
                      let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "No Permisson camera!!!"])
                      s.onError(error)
                    }
                })
                return Disposables.create()
            })
        default:
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "No Permisson camera!!!"])
            return Observable.error(error)
        }
    }
    
    private func presentAlert(message: String) {
        let actionCancel = AlertAction(style: .default, title: Text.dismiss.localizedText, handler: {})
        AlertVC.show(on: viewController.uiviewController, title: "Vato", message: message, from: [actionCancel], orderType: .horizontal)
    }
    
    func routeToScanQR() {
        guard let i = interactor as? Interactor else {
            return
        }
        requestPermissonCamera().observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] _ in
            guard let wSelf = self else { return }
            let route = wSelf.scanQRBuildable.build(withListener: wSelf.interactor)
            let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
            wSelf.perform(with: segue, completion: nil)
        }, onError: {[weak self] (e) in
            self?.presentAlert(message: Text.authorizeOpenCameraScanTicket.localizedText)
        }).disposeOnDeactivate(interactor: i)
    }
    
    func showRatingView(book: FCBooking) {
        let ratingView = FCEvaluteView()
        ratingView.booking = book
        ratingView.reloadData()
        ratingView.bounds = self.viewControllable.uiviewController.tabBarController?.view.bounds ?? UIScreen.main.bounds
        self.viewControllable.uiviewController.tabBarController?.view.addSubview(ratingView)
        ratingView.show()
        ratingView.setActionCallback { (index) in
            // 0: cancel, 1: done
            if index == 1 {
                ratingView.removeFromSuperview()
            }
        }
    }
    
    func presentLatePayment(with debtInfo: UserDebtDTO) {
        let router = latePaymentBuilder.build(withListener: interactor, debtInfo: debtInfo)
        let transition = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: transition, completion: nil)
    }
    
    func routeToInTrip(by tripId: String) {
        let route = inTripBuildable.build(withListener: interactor, tripId: tripId)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false)
                perform(with: segue, completion: nil)
    }
}

extension VatoMainRouter: TopUpHandlerResultProtocol {
    func topHandlerResult() {
        self.viewController.uiviewController.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.interactor.reloadBalance()
        })
    }
}

// MARK: Class's private methods
private extension VatoMainRouter {
    func setupRX() {
        guard let i = interactor as? Interactor else {
            return
        }
        
        self.handlerTrip.state.bind(onNext: { [weak self]action in
            switch action {
            case .cancel, .completed, .dismiss, .clientCancel:
                break
            case .newTrip:
                self?.interactor.newTrip()
            }
        }).disposeOnDeactivate(interactor: i)
    }
}
