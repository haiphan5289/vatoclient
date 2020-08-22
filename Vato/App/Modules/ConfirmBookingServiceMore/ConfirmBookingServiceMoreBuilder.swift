//  File name   : ConfirmBookingServiceMoreBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 11/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ConfirmBookingServiceMoreDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var confirmStream: ConfirmStreamImpl { get }
}

final class ConfirmBookingServiceMoreComponent: Component<ConfirmBookingServiceMoreDependency> {
    /// Class's public properties.
    let ConfirmBookingServiceMoreVC: ConfirmBookingServiceMoreVC
    
    /// Class's constructor.
    init(dependency: ConfirmBookingServiceMoreDependency, ConfirmBookingServiceMoreVC: ConfirmBookingServiceMoreVC) {
        self.ConfirmBookingServiceMoreVC = ConfirmBookingServiceMoreVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ConfirmBookingServiceMoreBuildable: Buildable {
    func build(withListener listener: ConfirmBookingServiceMoreListener, listService: [AdditionalServices],  listCurrentSelectedService: [AdditionalServices]) -> ConfirmBookingServiceMoreRouting
}

final class ConfirmBookingServiceMoreBuilder: Builder<ConfirmBookingServiceMoreDependency>, ConfirmBookingServiceMoreBuildable {
    /// Class's constructor.
    override init(dependency: ConfirmBookingServiceMoreDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ConfirmBookingServiceMoreBuildable's members
    func build(withListener listener: ConfirmBookingServiceMoreListener, listService: [AdditionalServices],  listCurrentSelectedService: [AdditionalServices]) -> ConfirmBookingServiceMoreRouting {
        let vc = ConfirmBookingServiceMoreVC(nibName: ConfirmBookingServiceMoreVC.identifier, bundle: nil)
        let component = ConfirmBookingServiceMoreComponent(dependency: dependency, ConfirmBookingServiceMoreVC: vc)
        
        let interactor = ConfirmBookingServiceMoreInteractor(presenter: component.ConfirmBookingServiceMoreVC, confirmStream: component.dependency.confirmStream, listService: listService, listCurrentSelectedService: listCurrentSelectedService)
        interactor.listener = listener
        
        // todo: Create builder modules builders and inject into router here.
        
        return ConfirmBookingServiceMoreRouter(interactor: interactor, viewController: component.ConfirmBookingServiceMoreVC)
    }
}
