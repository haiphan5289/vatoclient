//  File name   : ScanQRInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCore
import FwiCoreRX
import RxCocoa
import Alamofire
import VatoNetwork

protocol ScanQRRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func openPhotoLibrary()
    func routeToResultScsan(type: ResultScanType)
    func inputCodeQR()
}

protocol ScanQRPresentable: Presentable {
    var listener: ScanQRPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func presentWebVC(url: URL?, title: String?, accessToken: String)
} 

enum ScanQRError: Error {
    case permissionPhoto
    case permissionCamera
    case noPhoto
    case noQRCode
    case orther(msg: String)
}

protocol ScanQRListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func scanQRMoveBack()
    func resultScanShowPromotions()
}

final class ScanQRInteractor: PresentableInteractor<ScanQRPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: ScanQRRouting?
    weak var listener: ScanQRListener?

    /// Class's constructor.
    init(presenter: ScanQRPresentable,
                  authenticated: AuthenticatedStream) {
        self.authenticated = authenticated
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private lazy var mError: PublishSubject<ScanQRError> = PublishSubject()
    private lazy var processing: BehaviorRelay<ScanQRStep> = BehaviorRelay(value: .none)
    private var authenticated: AuthenticatedStream
}

// MARK: ScanQRInteractable's members
extension ScanQRInteractor: ScanQRInteractable {
    
    func resultScanMoveBack() {
        listener?.scanQRMoveBack()
    }
    
    func resultScanShowPromotions() {
        listener?.resultScanShowPromotions()
    }
    
    func handler(qrCode: String?) {
        guard let code = qrCode else {
            handler(error: .noQRCode)
            return
        }
        
        if let url = URL(string: code), UIApplication.shared.canOpenURL(url) {
            self.authenticated.firebaseAuthToken.take(1).bind {[weak self] (token) in
                guard let me = self else { return }
                me.presenter.presentWebVC(url: url, title: nil, accessToken: token)

            }.disposeOnDeactivate(interactor: self)
            return
        }
        
        processing.take(1)
            .filter { $0 != .loading(load: true, progress: 0) && $0 != .result }
            .flatMap { [weak self] (_) -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                return self.authenticated.firebaseAuthToken.take(1)
            }.flatMap({ (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<ScanQRResult>)> in
                self.processing.accept(.loading(load: true, progress: 0))
                return Requester.requestDTO(using: VatoTicketApi.checkQRCode(authToken: token, qrCode: code),
                                     method: .post, encoding: JSONEncoding.default).trackProgressActivity(self.indicator)
            }).observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self](response) in
                self?.processing.accept(.result)
                var resultType = ResultScanType.other
                if let model = response.1.data {
                    resultType = ResultScanType.success(resultScal: model)
                } else {
                    resultType = ResultScanType.createType(message: response.1.message)
                }

                self?.router?.routeToResultScsan(type: resultType)
                }, onError: {[weak self] (error) in
                    var message = error.localizedDescription
                    if (error as NSError).code == NSURLErrorBadServerResponse {
                        message = Text.networkDownDescription.localizedText
                    }
                    self?.handler(error: .orther(msg: message))
            }).disposeOnDeactivate(interactor: self)
    }
    
    func handler(scanQRStep: ScanQRStep) {
        processing.accept(scanQRStep)
    }
    
    func handler(error: ScanQRError) {
        mError.onNext(error)
    }
    
}

// MARK: ScanQRPresentableListener's members
extension ScanQRInteractor: ScanQRPresentableListener {
    
    var stepProcessing: Observable<ScanQRStep> {
        return processing.observeOn(MainScheduler.asyncInstance)
    }
    
    var error: Observable<ScanQRError> {
        return mError.observeOn(MainScheduler.asyncInstance)
    }
    
    func openPhotoLibrary() {
        router?.openPhotoLibrary()
    }
    
    func inputCodeQR() {
        router?.inputCodeQR()
    }
    
    func scanQRMoveBack() {
        listener?.scanQRMoveBack()
    }
}

// MARK: Class's private methods
private extension ScanQRInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        indicator.asObservable().bind {[weak self] (flag, progress) in
            guard let value = self?.processing.value, value != .result else {
                return
            }
            self?.processing.accept(.loading(load: flag, progress: progress))
        }.disposeOnDeactivate(interactor: self)
    }
}
