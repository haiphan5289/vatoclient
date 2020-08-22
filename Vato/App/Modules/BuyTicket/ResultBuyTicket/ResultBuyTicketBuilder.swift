//  File name   : ResultBuyTicketBuilder.swift
//
//  Author      : vato.
//  Created date: 10/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ResultBuyTicketDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var buyTicketStream: BuyTicketStreamImpl { get }
}

final class ResultBuyTicketComponent: Component<ResultBuyTicketDependency> {
    /// Class's public properties.
    let resultBuyTicketVC: ResultBuyTicketVC
    
    /// Class's constructor.
    init(dependency: ResultBuyTicketDependency, resultBuyTicketVC: ResultBuyTicketVC) {
        self.resultBuyTicketVC = resultBuyTicketVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ResultBuyTicketBuildable: Buildable {
    func build(withListener listener: ResultBuyTicketListener,
               streamType: BuslineStreamType) -> ResultBuyTicketRouting
}

final class ResultBuyTicketBuilder: Builder<ResultBuyTicketDependency>, ResultBuyTicketBuildable {
    /// Class's constructor.
    override init(dependency: ResultBuyTicketDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ResultBuyTicketBuildable's members
    func build(withListener listener: ResultBuyTicketListener,
               streamType: BuslineStreamType) -> ResultBuyTicketRouting {
        var resultBuyTicketVC = ResultBuyTicketVC()
        let storyboard = UIStoryboard(name: "TicketInfo", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ResultBuyTicketVC") as? ResultBuyTicketVC {
            resultBuyTicketVC = vc
        }
        
        let component = ResultBuyTicketComponent(dependency: dependency, resultBuyTicketVC: resultBuyTicketVC)

        let interactor = ResultBuyTicketInteractor(presenter: component.resultBuyTicketVC,
                                                   buyTicketStream: dependency.buyTicketStream,
                                                   streamType: streamType)
        interactor.listener = listener
        let ticketRouteDetail = TicketDetailRouteBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return ResultBuyTicketRouter(interactor: interactor,
                                     viewController: component.resultBuyTicketVC,
                                     ticketDetailRouteBuildable: ticketRouteDetail)
    }
}
