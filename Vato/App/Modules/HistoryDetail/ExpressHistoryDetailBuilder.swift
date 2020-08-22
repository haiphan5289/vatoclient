//  File name   : ExpressHistoryDetailBuilder.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ExpressHistoryDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ExpressHistoryDetailComponent: Component<ExpressHistoryDetailDependency> {
    /// Class's public properties.
    let expressHistoryDetailVC: ExpressHistoryDetailVC
    
    /// Class's constructor.
    init(dependency: ExpressHistoryDetailDependency, expressHistoryDetailVC: ExpressHistoryDetailVC) {
        self.expressHistoryDetailVC = expressHistoryDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ExpressHistoryDetailBuildable: Buildable {
    func build(withListener listener: ExpressHistoryDetailListener) -> ExpressHistoryDetailRouting
}

final class ExpressHistoryDetailBuilder: Builder<ExpressHistoryDetailDependency>, ExpressHistoryDetailBuildable {
    /// Class's constructor.
    override init(dependency: ExpressHistoryDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ExpressHistoryDetailBuildable's members
    func build(withListener listener: ExpressHistoryDetailListener) -> ExpressHistoryDetailRouting {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        var vc = ExpressHistoryDetailVC()
        if let historyVC = storyboard.instantiateViewController(withIdentifier: "ExpressHistoryDetailVC") as? ExpressHistoryDetailVC {
            vc = historyVC
        }
        let component = ExpressHistoryDetailComponent(dependency: dependency, expressHistoryDetailVC: vc)

        let interactor = ExpressHistoryDetailInteractor(presenter: component.expressHistoryDetailVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ExpressHistoryDetailRouter(interactor: interactor, viewController: component.expressHistoryDetailVC)
    }
}
