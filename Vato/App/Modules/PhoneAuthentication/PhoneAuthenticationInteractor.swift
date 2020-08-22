//  File name   : PhoneAuthenticationInteractor.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol PhoneAuthenticationRouting: ViewableRouting {
    func routeToPhoneInput()
    func routeToPhoneVerification()
    func routeToRegister()
}

protocol PhoneAuthenticationPresentable: Presentable {
    var listener: PhoneAuthenticationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol PhoneAuthenticationListener: class {
    func completeAuthentication()
    func dismissPhoneAuthentication()
}

final class PhoneAuthenticationInteractor: PresentableInteractor<PhoneAuthenticationPresentable> {
    weak var router: PhoneAuthenticationRouting?
    weak var listener: PhoneAuthenticationListener?

    /// Class's constructor.
    init(presenter: PhoneAuthenticationPresentable,
         mutableAuthenticationPhoneInputState: MutableAuthenticationPhoneInputStateStream)
    {
        self.mutableAuthenticationPhoneInputState = mutableAuthenticationPhoneInputState
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
    }

    override func willResignActive() {
        super.willResignActive()
//        router?.dismissRoute(by: { _ in return true }, completion: nil)
    }

    /// Class's private properties.
    private let mutableAuthenticationPhoneInputState: MutableAuthenticationPhoneInputStateStream
}

// MARK: Class's private methods
private extension PhoneAuthenticationInteractor {
    private func setupRX() {
    }
}


// MARK: PhoneAuthenticationInteractable's members
extension PhoneAuthenticationInteractor: PhoneAuthenticationInteractable {
    func completeAuthentication() {
        listener?.completeAuthentication()
    }

    func requestToChange(state: PhoneInputState) {
        switch state {
        case .register:
            mutableAuthenticationPhoneInputState.vatoUser
                .observeOn(MainScheduler.instance)
                .bind { [weak self] (vatoUser) in
                    if let vatoUser = vatoUser, (vatoUser.fullName?.count ?? 0) > 0 {
                        self?.listener?.completeAuthentication()
                    } else {
                        self?.mutableAuthenticationPhoneInputState.change(phoneInputState: state)
                    }
                }
                .disposeOnDeactivate(interactor: self)

        default:
            mutableAuthenticationPhoneInputState.change(phoneInputState: state)
        }
    }
}

// MARK: PhoneAuthenticationPresentableListener's members
extension PhoneAuthenticationInteractor: PhoneAuthenticationPresentableListener {
    var phoneInputState: Observable<PhoneInputState> {
        return mutableAuthenticationPhoneInputState.phoneInputState
    }

    func handleBackAction() {
        mutableAuthenticationPhoneInputState.phoneInputState
            .take(1)
            .bind { [weak self] (state) in
                switch state {
                case .verify:
                    self?.requestToChange(state: .input)

                default:
                    self?.listener?.dismissPhoneAuthentication()
                }
            }
            .disposeOnDeactivate(interactor: self)
    }

    func handleReadyAction() {
        mutableAuthenticationPhoneInputState.phoneInputState
            .distinctUntilChanged { $0 == $1 }
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (state) in
                guard let wSelf = self, let router = wSelf.router else {
                    return
                }
                
                switch state {
                case .input:
                    router.routeToPhoneInput()

                case .verify:
                    router.routeToPhoneVerification()

                case .register:
                    router.routeToRegister()
                }
            }
            .disposeOnDeactivate(interactor: self)
    }
}
