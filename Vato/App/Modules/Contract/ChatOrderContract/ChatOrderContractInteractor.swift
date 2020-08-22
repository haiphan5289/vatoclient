//  File name   : ChatOrderContractInteractor.swift
//
//  Author      : Phan Hai
//  Created date: 21/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ChatOrderContractRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ChatOrderContractPresentable: Presentable {
    var listener: ChatOrderContractPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ChatOrderContractListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackOC()
}

final class ChatOrderContractInteractor: PresentableInteractor<ChatOrderContractPresentable> {
    /// Class's public properties.
    weak var router: ChatOrderContractRouting?
    weak var listener: ChatOrderContractListener?

    /// Class's constructor.
    override init(presenter: ChatOrderContractPresentable) {
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
}

// MARK: ChatOrderContractInteractable's members
extension ChatOrderContractInteractor: ChatOrderContractInteractable {
}

// MARK: ChatOrderContractPresentableListener's members
extension ChatOrderContractInteractor: ChatOrderContractPresentableListener {
    func moveBackOC() {
        self.listener?.moveBackOC()
    }
}

// MARK: Class's private methods
private extension ChatOrderContractInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
