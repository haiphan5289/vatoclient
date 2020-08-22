//  File name   : NoteInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 9/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol NoteRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NotePresentable: Presentable {
    var listener: NotePresentableListener? { get set }
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol NoteListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func cancelNote()
}

final class NoteInteractor: PresentableInteractor<NotePresentable>, NoteInteractable, NotePresentableListener {
    weak var router: NoteRouting?
    weak var listener: NoteListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: NotePresentable, note: MutableNoteStream) {
        self.note = note
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    func previousNote() -> Observable<String> {
        return self.note.valueNote.take(1)
    }

    func update(note text: String?) {
        self.note.update(note: text ?? "")
    }

    func cancel() {
        listener?.cancelNote()
    }

    /// Class's private properties.
    private let note: MutableNoteStream
}
