//  File name   : CancelTicketBuilder.swift
//
//  Author      : vato.
//  Created date: 10/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol CancelTicketDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var profileStream: MutableProfileStream { get }
}

final class CancelTicketComponent: Component<CancelTicketDependency> {
    /// Class's public properties.
    let CancelTicketVC: CancelTicketVC
    
    /// Class's constructor.
    init(dependency: CancelTicketDependency, CancelTicketVC: CancelTicketVC) {
        self.CancelTicketVC = CancelTicketVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol CancelTicketBuildable: Buildable {
    func build(withListener listener: CancelTicketListener,
               item: TicketHistoryType) -> CancelTicketRouting
}

final class CancelTicketBuilder: Builder<CancelTicketDependency>, CancelTicketBuildable {
    /// Class's constructor.
    override init(dependency: CancelTicketDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: CancelTicketBuildable's members
    func build(withListener listener: CancelTicketListener,
               item: TicketHistoryType) -> CancelTicketRouting {
        guard let vc = UIStoryboard(name: "CancellationTicket", bundle: nil).instantiateViewController(withIdentifier: CancelTicketVC.identifier) as? CancelTicketVC else { fatalError("Please Implement") }
        
        let component = CancelTicketComponent(dependency: dependency, CancelTicketVC: vc)

        let interactor = CancelTicketInteractor(presenter: component.CancelTicketVC,
                                                item: item,
                                                mutableProfile: dependency.profileStream,
                                                authenticatedStream: dependency.authenticatedStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return CancelTicketRouter(interactor: interactor, viewController: component.CancelTicketVC)
    }
}
