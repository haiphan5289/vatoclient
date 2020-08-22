//  File name   : ChatOrderContractBuilder.swift
//
//  Author      : Phan Hai
//  Created date: 21/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ChatOrderContractDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ChatOrderContractComponent: Component<ChatOrderContractDependency> {
    /// Class's public properties.
    let ChatOrderContractVC: ChatOrderContractVC
    
    /// Class's constructor.
    init(dependency: ChatOrderContractDependency, ChatOrderContractVC: ChatOrderContractVC) {
        self.ChatOrderContractVC = ChatOrderContractVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ChatOrderContractBuildable: Buildable {
    func build(withListener listener: ChatOrderContractListener) -> ChatOrderContractRouting
}

final class ChatOrderContractBuilder: Builder<ChatOrderContractDependency>, ChatOrderContractBuildable {
    /// Class's constructor.
    override init(dependency: ChatOrderContractDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ChatOrderContractBuildable's members
    func build(withListener listener: ChatOrderContractListener) -> ChatOrderContractRouting {
        let vc = ChatOrderContractVC(nibName: ChatOrderContractVC.identifier, bundle: nil)
        let component = ChatOrderContractComponent(dependency: dependency, ChatOrderContractVC: vc)

        let interactor = ChatOrderContractInteractor(presenter: component.ChatOrderContractVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ChatOrderContractRouter(interactor: interactor, viewController: component.ChatOrderContractVC)
    }
}
