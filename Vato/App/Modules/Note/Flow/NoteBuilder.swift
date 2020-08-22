//  File name   : NoteBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 9/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol NoteDependency: Dependency {
    var note: MutableNoteStream { get }
}

final class NoteComponent: Component<NoteDependency> {
    override init(dependency: NoteDependency) {
        super.init(dependency: dependency)
    }

    fileprivate var note: MutableNoteStream {
        return dependency.note
    }
}

// MARK: Builder
protocol NoteBuildable: Buildable {
    func build(withListener listener: NoteListener, previousNote: String?) -> NoteRouting
}

final class NoteBuilder: Builder<NoteDependency>, NoteBuildable {
    override init(dependency: NoteDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: NoteListener, previousNote: String?) -> NoteRouting {
        let component = NoteComponent(dependency: dependency)
        let viewController = NoteVC()

        let interactor = NoteInteractor(presenter: viewController, note: component.note)
        interactor.listener = listener

        return NoteRouter(interactor: interactor, viewController: viewController)
    }
}
