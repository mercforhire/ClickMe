//
//  NotificationMessage.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-22.
//

import Foundation

class NotificationMessage {
    var message: String
    var timestamp: Date
    var unread: Bool
    
    init(message: String, timestamp: Date, unread: Bool) {
        self.message = message
        self.timestamp = timestamp
        self.unread = unread
    }
    
    static func random(timestamp: Date, unread: Bool = false) -> NotificationMessage {
        return NotificationMessage(message: Lorem.sentences(Int.random(in: 1...4)), timestamp: timestamp, unread: unread)
    }
}
