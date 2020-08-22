//  File name   : CancelTicketInteractor.swift
//
//  Author      : vato.
//  Created date: 10/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import VatoNetwork
import RxSwift
import Alamofire
import FwiCore
import FwiCoreRX

protocol CancelTicketRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol CancelTicketPresentable: Presentable {
    var listener: CancelTicketPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol CancelTicketListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func cancelTicketMoveBack()
    func cancelTicketSuccess(item: TicketHistoryType)
}

final class CancelTicketInteractor: PresentableInteractor<CancelTicketPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: CancelTicketRouting?
    weak var listener: CancelTicketListener?

    /// Class's constructor.
    init(presenter: CancelTicketPresentable,
         item: TicketHistoryType,
         mutableProfile: ProfileStream,
         authenticatedStream: AuthenticatedStream) {
        self.item = item
        self.mutableProfile = mutableProfile
        self.authenticatedStream = authenticatedStream
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
    internal let item: TicketHistoryType
    private let authenticatedStream: AuthenticatedStream
    private let mutableProfile: ProfileStream
    private lazy var mErrorSubject: PublishSubject<BuyTicketPaymenState> = PublishSubject()
}

// MARK: CancelTicketInteractable's members
extension CancelTicketInteractor: CancelTicketInteractable {
}

// MARK: CancelTicketPresentableListener's members
extension CancelTicketInteractor: CancelTicketPresentableListener {
    func cancelTicketSuccess() {
        listener?.cancelTicketSuccess(item: item)
    }
    
    var loading: Observable<(Bool, Double)> {
        return self.indicator.asObservable()
    }
    
    func moveBack() {
        listener?.cancelTicketMoveBack()
    }
    
    func cancelTicket() {
        mutableProfile.client.take(1).subscribe(onNext: { [weak self] (client) in
            guard let userId = client.user?.id else { return }
            self?.requestCancel(userId: userId)
        }).disposeOnDeactivate(interactor: self)
    }
    
    var _error: Observable<BuyTicketPaymenState> {
        return mErrorSubject.asObserver()
    }
}

// MARK: Class's private methods
private extension CancelTicketInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    private func requestCancel(userId: Int64) {
        guard let code = self.item.code else { return }
        
        let bookCancelVato: Int = 1
        // BOOKING_CACEL_VATO(1, "CANCEL BY APP VATO", "Huỷ vé từ app VATO"),
        self.authenticatedStream
            .firebaseAuthToken
            .take(1)
            .flatMap{ (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<TicketHistoryType>)> in
                Requester.requestDTO(using: VatoTicketApi.cancelTicket(authToken: token, ticketsCode: code, userId: userId, status: bookCancelVato), method: .put, encoding: JSONEncoding.default)
            }.observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: {[weak self] (r) in
                if r.1.fail == true {
                    let errType = BuyTicketPaymenState.generateError(status: r.1.status, message: r.1.message)
                    self?.mErrorSubject.onNext(errType)
                } else {
                    self?.mErrorSubject.onNext(.success)
                    NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
                }
                }, onError: {[weak self] (e) in
                    self?.mErrorSubject.onNext(.errorSystem(err: e))
            }).disposeOnDeactivate(interactor: self)
    }
    
}
