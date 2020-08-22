//  File name   : TicketChooseDestinationBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

enum DestinationType {
    case origin
    case destination
    
    var title: String {
        switch self {
        case .origin:
            return Text.selectOriginLocationTicket.localizedText
        case .destination:
            return Text.selectDestinationLocationTicket.localizedText
        }
    }
}

struct ChooseDestinationParam {
    var destinationType: DestinationType = .origin
    var originCode: String?
    var destinationCode: String?
}

// MARK: Dependency tree
protocol TicketChooseDestinationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
}

final class TicketChooseDestinationComponent: Component<TicketChooseDestinationDependency> {
    /// Class's public properties.
    let TicketChooseDestinationVC: TicketChooseDestinationVC
//
    /// Class's constructor.
    init(dependency: TicketChooseDestinationDependency, TicketChooseDestinationVC: TicketChooseDestinationVC) {
        self.TicketChooseDestinationVC = TicketChooseDestinationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketChooseDestinationBuildable: Buildable {
    func build(withListener listener: TicketChooseDestinationListener, param: ChooseDestinationParam) -> TicketChooseDestinationRouting
}

final class TicketChooseDestinationBuilder: Builder<TicketChooseDestinationDependency>, TicketChooseDestinationBuildable {
    /// Class's constructor.
    override init(dependency: TicketChooseDestinationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketChooseDestinationBuildable's members
    func build(withListener listener: TicketChooseDestinationListener, param: ChooseDestinationParam) -> TicketChooseDestinationRouting {
        let vc = TicketChooseDestinationVC(nibName: TicketChooseDestinationVC.identifier, bundle: nil, param: param)
        let component = TicketChooseDestinationComponent(dependency: dependency, TicketChooseDestinationVC: vc)

        let interactor = TicketChooseDestinationInteractor(presenter: component.TicketChooseDestinationVC, authStream: component.dependency.authenticatedStream)
        interactor.listener = listener
        // todo: Create builder modules builders and inject into router here.
        
        return TicketChooseDestinationRouter(interactor: interactor, viewController: component.TicketChooseDestinationVC)
    }
}
