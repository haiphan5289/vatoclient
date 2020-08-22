//  File name   : ResultBuyTicketInteractor.swift
//
//  Author      : vato.
//  Created date: 10/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol ResultBuyTicketRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToTicketRouteDetail(_ info: DetailRouteInfo)
}

protocol ResultBuyTicketPresentable: Presentable {
    var listener: ResultBuyTicketPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ResultBuyTicketListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func resultBuyTicketMoveBack()
    func moveManagerTicket()
    func moveBackBuyNewTicket()
}

final class ResultBuyTicketInteractor: PresentableInteractor<ResultBuyTicketPresentable> {
    /// Class's public properties.
    weak var router: ResultBuyTicketRouting?
    weak var listener: ResultBuyTicketListener?

    /// Class's constructor.
    init(presenter: ResultBuyTicketPresentable,
         buyTicketStream: BuyTicketStreamImpl,
         streamType: BuslineStreamType) {
        
        self.streamType = streamType
        self.buyTicketStream = buyTicketStream
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
    let buyTicketStream: BuyTicketStreamImpl
    internal let streamType: BuslineStreamType
}

// MARK: ResultBuyTicketInteractable's members
extension ResultBuyTicketInteractor: ResultBuyTicketInteractable, ActivityTrackingProgressProtocol {
    func ticketDetailRouteMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func requestDetailTicketRoute(item: TicketHistoryType?) {
        guard let value = item else {
            return
        }
        
        guard let routeId = value.routeId,
            let wayID = value.wayId else
        {
            return
        }
        
        let url = "\(VatoTicketApi.host)/buslines/futa/routes/\(routeId)/roadmap?wayId=\(wayID)"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[DetailRoute]>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail == false {
                        var item = DetailRouteInfo()
                        item.listDetailRoute = d.data ?? []
                        item.nameFrom = value.originName
                        item.nameTo = value.destName
                        item.departureTime = value.departureTime
                        item.departureDate = value.departureDate
                        wSelf.showTicketRouteDetail(item)
                    } else {
                        print(d.message ?? "")
                  }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func showTicketRouteDetail(_ info: DetailRouteInfo) {
        router?.routeToTicketRouteDetail(info)
    }
}

// MARK: ResultBuyTicketPresentableListener's members
extension ResultBuyTicketInteractor: ResultBuyTicketPresentableListener {
   
    func moveBackBuyNewTicket() {
        listener?.moveBackBuyNewTicket()
    }
    
    func moveBack() {
        listener?.resultBuyTicketMoveBack()
    }

    var ticketModel: TicketInformation {
        return buyTicketStream.ticketModel
    }
    
    var ticketModelDetail: TicketHistoryType? {
        return buyTicketStream.ticketModel.detail
    }
    
    func moveManagerTicket() {
        listener?.moveManagerTicket()
    }
}

// MARK: Class's private methods
private extension ResultBuyTicketInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
