//  File name   : NoteBuilder.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol NoteDependency: Dependency {
    // todo: Make sure to convert the variable into lower-camelcase.
    var noteVC: NoteViewControllable { get }

    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class NoteComponent: Component<NoteDependency> {
    // todo: Make sure to convert the variable into lower-camelcase.
    fileprivate var noteVC: NoteViewControllable {
        return dependency.noteVC
    }

    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol NoteBuildable: Buildable {
    func build(withListener listener: NoteListener) -> NoteRouting
}

final class NoteBuilder: Builder<NoteDependency>, NoteBuildable {
    override init(dependency: NoteDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: NoteListener) -> NoteRouting {
        let component = NoteComponent(dependency: dependency)
        let interactor = NoteInteractor()
        interactor.listener = listener

        return NoteRouter(interactor: interactor, viewController: component.noteVC)
    }
}
