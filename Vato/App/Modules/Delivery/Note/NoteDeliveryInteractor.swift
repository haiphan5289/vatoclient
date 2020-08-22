//  File name   : NoteDeliveryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

struct NoteTextConfig {
    var titleText: String? = Text.noteTitle.localizedText
    var notePlaceholder: String? = Text.notePakage.localizedText
    var confirmButton: String? = Text.confirm.localizedText
}

protocol NoteDeliveryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NoteDeliveryPresentable: Presentable {
    var listener: NoteDeliveryPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol NoteDeliveryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismiss()
    func updateNote(note: NoteDeliveryModel)
}

final class NoteDeliveryInteractor: PresentableInteractor<NoteDeliveryPresentable> {
    
    /// Class's public properties.
    weak var router: NoteDeliveryRouting?
    weak var listener: NoteDeliveryListener?

    /// Class's constructor.
    init(presenter: NoteDeliveryPresentable,
         noteTextConfig: NoteTextConfig?) {
        self.noteTextConfig = noteTextConfig ?? NoteTextConfig()
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    internal let noteTextConfig: NoteTextConfig
}

// MARK: NoteDeliveryInteractable's members
extension NoteDeliveryInteractor: NoteDeliveryInteractable {
}

// MARK: NoteDeliveryPresentableListener's members
extension NoteDeliveryInteractor: NoteDeliveryPresentableListener {
    func update(note: NoteDeliveryModel) {
        listener?.updateNote(note: note)
    }
    
    func moveBack() {
        listener?.dismiss()
    }
}

// MARK: Class's private methods
private extension NoteDeliveryInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
