//  File name   : ConfirmBookingServiceMoreInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 11/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ConfirmBookingServiceMoreRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ConfirmBookingServiceMorePresentable: Presentable {
    var listener: ConfirmBookingServiceMorePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ConfirmBookingServiceMoreListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dimissServiceMore()
    func confirmBookingService(arrayServiceMore: [AdditionalServices])
}

final class ConfirmBookingServiceMoreInteractor: PresentableInteractor<ConfirmBookingServiceMorePresentable> {
    /// Class's public properties.
    weak var router: ConfirmBookingServiceMoreRouting?
    weak var listener: ConfirmBookingServiceMoreListener?
    private var confirmStream: ConfirmStreamImpl
    private var listCurrentSelectedService: [AdditionalServices]
    private var listService: [AdditionalServices]
    /// Class's constructor.
    init(presenter: ConfirmBookingServiceMorePresentable, confirmStream: ConfirmStreamImpl, listService: [AdditionalServices], listCurrentSelectedService: [AdditionalServices]) {
        self.confirmStream = confirmStream
        self.listCurrentSelectedService = listCurrentSelectedService
        self.listService = listService
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
}


extension ConfirmBookingServiceMoreInteractor: ConfirmBookingServiceMoreInteractable {
}

// MARK: ConfirmBookingServiceMorePresentableListener's members
extension ConfirmBookingServiceMoreInteractor: ConfirmBookingServiceMorePresentableListener {
    var listAdditionalServiceObserable: Observable<[AdditionalServices]> {
        return Observable.just(listService)
    }
    
    func getListServiceMore(arrayServiceMore: [AdditionalServices]) {
        self.listener?.confirmBookingService(arrayServiceMore: arrayServiceMore)
    }
    
    func dismiss() {
        self.listener?.dimissServiceMore()
    }
    
    var currentSelectedService: [AdditionalServices] {
        return self.listCurrentSelectedService
    }

}

// MARK: Class's private methods
private extension ConfirmBookingServiceMoreInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}

