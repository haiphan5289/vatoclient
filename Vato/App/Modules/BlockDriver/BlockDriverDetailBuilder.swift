//  File name   : BlockDriverDetailBuilder.swift
//
//  Author      : admin
//  Created date: 6/25/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BlockDriverDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class BlockDriverDetailComponent: Component<BlockDriverDetailDependency> {
    /// Class's public properties.
    let BlockDriverDetailVC: BlockDriverDetailVC
    
    /// Class's constructor.
    init(dependency: BlockDriverDetailDependency, BlockDriverDetailVC: BlockDriverDetailVC) {
        self.BlockDriverDetailVC = BlockDriverDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BlockDriverDetailBuildable: Buildable {
//    func build(withListener listener: BlockDriverDetailListener) -> BlockDriverDetailRouting
    func build(withListener listener: BlockDriverDetailListener, driver: BlockDriverInfo) -> BlockDriverDetailRouting
}

final class BlockDriverDetailBuilder: Builder<BlockDriverDetailDependency>, BlockDriverDetailBuildable {
    
    /// Class's constructor.
    override init(dependency: BlockDriverDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BlockDriverDetailBuildable's members
    func build(withListener listener: BlockDriverDetailListener, driver: BlockDriverInfo) -> BlockDriverDetailRouting {
//        let vc = BlockDriverDetailVC()
        guard let vc = UIStoryboard(name: "BlockDriverDetailVC", bundle: nil).instantiateViewController(withIdentifier: "driverdetail") as? BlockDriverDetailVC else { fatalError("Please Implement") }

        let component = BlockDriverDetailComponent(dependency: dependency, BlockDriverDetailVC: vc)

        let interactor = BlockDriverDetailInteractor(presenter: component.BlockDriverDetailVC, driver: driver)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return BlockDriverDetailRouter(interactor: interactor, viewController: component.BlockDriverDetailVC)
    }
}
