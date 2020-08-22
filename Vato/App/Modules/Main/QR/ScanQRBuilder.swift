//  File name   : ScanQRBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ScanQRDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutableAuthenticated: MutableAuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
}

final class ScanQRComponent: Component<ScanQRDependency> {
    /// Class's public properties.
    let ScanQRVC: ScanQRVC
    
    /// Class's constructor.
    init(dependency: ScanQRDependency, ScanQRVC: ScanQRVC) {
        self.ScanQRVC = ScanQRVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ScanQRBuildable: Buildable {
    func build(withListener listener: ScanQRListener) -> ScanQRRouting
}

final class ScanQRBuilder: Builder<ScanQRDependency>, ScanQRBuildable {
    /// Class's constructor.
    override init(dependency: ScanQRDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ScanQRBuildable's members
    func build(withListener listener: ScanQRListener) -> ScanQRRouting {
        let vc = ScanQRVC(nibName: ScanQRVC.identifier, bundle: nil)
        let component = ScanQRComponent(dependency: dependency, ScanQRVC: vc)

        let interactor = ScanQRInteractor(presenter: component.ScanQRVC,
                                          authenticated: component.dependency.mutableAuthenticated)
        interactor.listener = listener

        let resultScanBuilder = ResultScanBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return ScanQRRouter(interactor: interactor, viewController: component.ScanQRVC, resultScanBuilder: resultScanBuilder)
    }
}
