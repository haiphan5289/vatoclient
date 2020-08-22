//  File name   : TicketDetailRouteInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 5/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol TicketDetailRouteRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TicketDetailRoutePresentable: Presentable {
    var listener: TicketDetailRoutePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TicketDetailRouteListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketDetailRouteMoveBack()
}

final class TicketDetailRouteInteractor: PresentableInteractor<TicketDetailRoutePresentable> {
    /// Class's public properties.
    weak var router: TicketDetailRouteRouting?
    weak var listener: TicketDetailRouteListener?
    private let itemDetail: DetailRouteInfo

    /// Class's constructor.
    init(presenter: TicketDetailRoutePresentable, itemDetail: DetailRouteInfo) {
        self.itemDetail = itemDetail
        super.init(presenter: presenter)
        presenter.listener = self
    }
    @Replay(queue: MainScheduler.asyncInstance) private var mItemDetaiRoute: DetailRouteInfo

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        mItemDetaiRoute = self.itemDetail
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: TicketDetailRouteInteractable's members
extension TicketDetailRouteInteractor: TicketDetailRouteInteractable {
}

// MARK: TicketDetailRoutePresentableListener's members
extension TicketDetailRouteInteractor: TicketDetailRoutePresentableListener {
    var itemDetailRouteInfo: Observable<DetailRouteInfo> {
        return $mItemDetaiRoute.asObservable()
    }
    func ticketDetailRouteMoveBack() {
        self.listener?.ticketDetailRouteMoveBack()
    }
    
}

// MARK: Class's private methods
private extension TicketDetailRouteInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
