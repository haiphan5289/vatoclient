//  File name   : BlockDriverBuilder.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BlockDriverDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class BlockDriverComponent: Component<BlockDriverDependency> {
    /// Class's public properties.
    let BlockDriverVC: BlockDriverVC
    
    /// Class's constructor.
    init(dependency: BlockDriverDependency, BlockDriverVC: BlockDriverVC) {
        self.BlockDriverVC = BlockDriverVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BlockDriverBuildable: Buildable {
    func build(withListener listener: BlockDriverListener) -> BlockDriverRouting
}

final class BlockDriverBuilder: Builder<BlockDriverDependency>, BlockDriverBuildable {
    /// Class's constructor.
    override init(dependency: BlockDriverDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BlockDriverBuildable's members
    func build(withListener listener: BlockDriverListener) -> BlockDriverRouting {
//        let vc = BlockDriverVC()
        guard let vc = UIStoryboard(name: "BlockDriverDetailVC", bundle: nil).instantiateViewController(withIdentifier: "blockDriver") as? BlockDriverVC else { fatalError("Please Implement") }

        let component = BlockDriverComponent(dependency: dependency, BlockDriverVC: vc)

        let interactor = BlockDriverInteractor(presenter: component.BlockDriverVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let findDriverBuilder = FindDriverBuilder(dependency: component)
        let detailDriverBuilder = BlockDriverDetailBuilder(dependency: component)

        return BlockDriverRouter(interactor: interactor, viewController: component.BlockDriverVC, findDriverBuildable: findDriverBuilder, detailBlockDriverBuildable: detailDriverBuilder)
    }
}
