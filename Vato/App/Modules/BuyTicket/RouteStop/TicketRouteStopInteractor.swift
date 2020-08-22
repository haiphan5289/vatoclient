//  File name   : TicketRouteStopInteractor.swift
//
//  Author      : khoi tran
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

protocol TicketRouteStopRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TicketRouteStopPresentable: Presentable {
    var listener: TicketRouteStopPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TicketRouteStopListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismissRouteStop()
    func didSelectRouteStop(routeStop: RouteStop)
}

final class TicketRouteStopInteractor: PresentableInteractor<TicketRouteStopPresentable> {
    /// Class's public properties.
    weak var router: TicketRouteStopRouting?
    weak var listener: TicketRouteStopListener?

    /// Class's constructor.
    init(presenter: TicketRouteStopPresentable, routeStopParam: ChooseRouteStopParam?, currentRouteStopId: Int?, listRouteStop: [RouteStop]?) {
        self.routeStopParam = routeStopParam
        self.mCurrentRouteStopId = currentRouteStopId
        self.mlistRouteStop = listRouteStop
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        getListStop(with: self.routeStopParam)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    @Replay(queue: MainScheduler.asyncInstance) private var eListRouteStop: [RouteStop]
    
    private var routeStopParam: ChooseRouteStopParam?
    private var mCurrentRouteStopId: Int?
    private var mlistRouteStop: [RouteStop]?
}

// MARK: TicketRouteStopInteractable's members
extension TicketRouteStopInteractor: TicketRouteStopInteractable {
}

// MARK: TicketRouteStopPresentableListener's members
extension TicketRouteStopInteractor: TicketRouteStopPresentableListener {
    
    var listRouteStop: Observable<[RouteStop]> {
        return $eListRouteStop
    }
    
    var currentRouteStopId: Int? {
        return mCurrentRouteStopId
    }
    
    func dismissRouteStop() {
        self.listener?.dismissRouteStop()
        
    }
    func didSelectRouteStop(routeStop: RouteStop) {
        self.listener?.didSelectRouteStop(routeStop: routeStop)
    }
    
    func getListStop(with routeStopParam: ChooseRouteStopParam?) {
        if let mlistRouteStop = mlistRouteStop {
            self.eListRouteStop = mlistRouteStop
        } else {
            guard let routeId = routeStopParam?.routeId,
                let departureDate = routeStopParam?.departureDate,
                let departureTime = routeStopParam?.departureTime,
                let wayId = routeStopParam?.wayId else { return }
            
            let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
            let router = VatoTicketApi.listStop(authToken: "", routeId: routeId, departureDate: departureDate, departureTime: departureTime, wayId: wayId)
            
            network.request(using: router, decodeTo: OptionalMessageDTO<[RouteStop]>.self).bind {[weak self] (r) in
                guard let wSelf = self else { return }
                
                switch r {
                case .success(let d):
                    wSelf.eListRouteStop = d.data ?? []
                case .failure(_):
                    wSelf.eListRouteStop = []
                }
            }.disposeOnDeactivate(interactor: self)
        }
    
    }
    
}

// MARK: Class's private methods
private extension TicketRouteStopInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
