//
//  GroundChatRoom.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-17.
//

import Foundation

enum GroupChatRoomType: Int {
    case openToPublic
    case friendsOnly
    case privateRoom
}

struct GroupChatRoom: Equatable {
    var identifier: Int = 0
    var type: GroupChatRoomType = .openToPublic
    var host: ListUser
    var mood: Mood
    var title: String
    var speakers: [ListUser] = []
    var guests: [ListUser] = []
    var startDate: Date
    var duration: Int
    var log: [String] = []
    
    var aboutToStart: Bool {
        return startDate.isInSameDay(date: Date()) && Date().hour() == startDate.hour()
    }
    
    static func ==(lhs: GroupChatRoom, rhs: GroupChatRoom) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
