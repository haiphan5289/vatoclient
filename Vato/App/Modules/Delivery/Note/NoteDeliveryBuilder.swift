//  File name   : NoteDeliveryBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol NoteDeliveryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class NoteDeliveryComponent: Component<NoteDeliveryDependency> {
    /// Class's public properties.
    let NoteDeliveryVC: NoteDeliveryVC
    
    /// Class's constructor.
    init(dependency: NoteDeliveryDependency, NoteDeliveryVC: NoteDeliveryVC) {
        self.NoteDeliveryVC = NoteDeliveryVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol NoteDeliveryBuildable: Buildable {
    func build(withListener listener: NoteDeliveryListener,
               noteDelivery: NoteDeliveryModel?,
               noteTextConfig: NoteTextConfig?) -> NoteDeliveryRouting
}

final class NoteDeliveryBuilder: Builder<NoteDeliveryDependency>, NoteDeliveryBuildable {

    /// Class's constructor.
    override init(dependency: NoteDeliveryDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: NoteDeliveryBuildable's members
    func build(withListener listener: NoteDeliveryListener, noteDelivery: NoteDeliveryModel?, noteTextConfig: NoteTextConfig?) -> NoteDeliveryRouting {
        let vc = NoteDeliveryVC(nibName: NoteDeliveryVC.identifier, bundle: nil, noteDelivery: noteDelivery)
        let component = NoteDeliveryComponent(dependency: dependency, NoteDeliveryVC: vc)

        let interactor = NoteDeliveryInteractor(presenter: component.NoteDeliveryVC,
                                                noteTextConfig: noteTextConfig)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return NoteDeliveryRouter(interactor: interactor, viewController: component.NoteDeliveryVC)
    }
}
