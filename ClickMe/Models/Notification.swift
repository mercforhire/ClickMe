//
//  Notification.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-17.
//

import Foundation

struct Message {
    var userId: String
    var message: String
    var timestamp: Date
    var unread: Bool
    
    static func random(userId: String, timestamp: Date, unread: Bool = false) -> Message {
        return Message(userId: userId, message: Lorem.sentences(Int.random(in: 1...4)), timestamp: timestamp, unread: unread)
    }
}
