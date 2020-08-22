//  File name   : ResultScanBuilder.swift
//
//  Author      : vato.
//  Created date: 9/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ResultScanDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ResultScanComponent: Component<ResultScanDependency> {
    /// Class's public properties.
    let ResultScanVC: ResultScanVC
    
    /// Class's constructor.
    init(dependency: ResultScanDependency, ResultScanVC: ResultScanVC) {
        self.ResultScanVC = ResultScanVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ResultScanBuildable: Buildable {
    func build(withListener listener: ResultScanListener, resultScanType: ResultScanType) -> ResultScanRouting
}

final class ResultScanBuilder: Builder<ResultScanDependency>, ResultScanBuildable {
    /// Class's constructor.
    override init(dependency: ResultScanDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ResultScanBuildable's members
    func build(withListener listener: ResultScanListener, resultScanType: ResultScanType) -> ResultScanRouting {
        let vc = ResultScanVC(nibName: ResultScanVC.identifier, bundle: nil)
        let component = ResultScanComponent(dependency: dependency, ResultScanVC: vc)

        let interactor = ResultScanInteractor(presenter: component.ResultScanVC, resultScanType: resultScanType)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ResultScanRouter(interactor: interactor, viewController: component.ResultScanVC)
    }
}
