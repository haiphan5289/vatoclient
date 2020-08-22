//  File name   : ChatInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 1/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ChatRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ChatPresentable: Presentable {
    var listener: ChatPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ChatListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func chatMoveBack()
    func send(message: String)
}

final class ChatInteractor: PresentableInteractor<ChatPresentable>, ChatInteractable, ChatPresentableListener {

    weak var router: ChatRouting?
    weak var listener: ChatListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: ChatPresentable, profileStream: ProfileStream, chatStream: ChatStream) {
        self.profileStream = profileStream
        self.chatStream = chatStream
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
    
    private (set) var profileStream: ProfileStream
    private (set) var chatStream: ChatStream
}

extension ChatInteractor {
    func sendMessage(_ message: String) {
        listener?.send(message: message)
    }
    
    func chatMoveBack() {
        listener?.chatMoveBack()
    }
}
