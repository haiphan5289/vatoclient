//  File name   : ChatMessage.swift
//
//  Author      : Dung Vu
//  Created date: 1/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Firebase

struct ChatMessage: Codable, ModelFromFireBaseProtocol, ChatMessageProtocol, Comparable {
    var message: String?
    var sender: String?
    var receiver: String?
    let id: Int64
    let time: TimeInterval
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.time == rhs.time
    }
    
    static func < (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.time < rhs.time
    }
}

protocol ChatMessageProtocol {
    var message: String? { get }
    var sender: String? { get }
    var receiver: String? { get }
    var id: Int64 { get }
    var time: TimeInterval { get }
}

