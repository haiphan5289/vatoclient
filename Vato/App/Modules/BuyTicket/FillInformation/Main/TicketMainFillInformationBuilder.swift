//  File name   : TicketMainFillInformationBuilder.swift
//
//  Author      : khoi tran
//  Created date: 5/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol TicketMainFillInformationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var buyTicketStream: BuyTicketStreamImpl { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var authStream: AuthenticatedStream { get }
}

final class TicketMainFillInformationComponent: Component<TicketMainFillInformationDependency> {
    /// Class's public properties.
    let TicketMainFillInformationVC: TicketMainFillInformationVC
    
    /// Class's constructor.
    init(dependency: TicketMainFillInformationDependency, TicketMainFillInformationVC: TicketMainFillInformationVC) {
        self.TicketMainFillInformationVC = TicketMainFillInformationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketMainFillInformationBuildable: Buildable {
    func build(withListener listener: TicketMainFillInformationListener) -> TicketMainFillInformationRouting
}

final class TicketMainFillInformationBuilder: Builder<TicketMainFillInformationDependency>, TicketMainFillInformationBuildable {
    /// Class's constructor.
    override init(dependency: TicketMainFillInformationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketMainFillInformationBuildable's members
    func build(withListener listener: TicketMainFillInformationListener) -> TicketMainFillInformationRouting {
        let vc = TicketMainFillInformationVC(nibName: TicketMainFillInformationVC.identifier, bundle: nil)
        let component = TicketMainFillInformationComponent(dependency: dependency, TicketMainFillInformationVC: vc)

        let interactor = TicketMainFillInformationInteractor(presenter: component.TicketMainFillInformationVC, streamType: .buyNewticket, profileStream: component.dependency.mutableProfile, buyTicketStream: component.dependency.buyTicketStream, authStream: component.dependency.authStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let ticketFillInformationBuilbable = TicketFillInformationBuilder(dependency: component)
        
        let buyTicketPaymentBuildable = BuyTicketPaymentBuilder(dependency: component)

        
        return TicketMainFillInformationRouter(interactor: interactor, viewController: component.TicketMainFillInformationVC, ticketFillInformationBuildable: ticketFillInformationBuilbable, buyTicketPaymentBuildable: buyTicketPaymentBuildable)
    }
}
