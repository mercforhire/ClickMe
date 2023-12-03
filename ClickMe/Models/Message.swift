//
//  Message.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-17.
//
import Foundation

struct Message: Codable, ItemWithTimeStamp {
    var chatMessage: ChatMessage
    var user: ListUser
    var schedule: SimpleSchedule?
    
    enum CodingKeys: String, CodingKey {
        case chatMessage = "chatMsg"
        case user
        case schedule
    }
    
    func getTimeStamp() -> Date {
        return chatMessage.timeStamp
    }
    
    var isFromMyself: Bool {
        return UserManager.shared.user?.identifier == chatMessage.fromUser
    }
}

struct ChatMessage: Codable {
    var identifier: Int
    var fromUser: Int
    var toUser: Int
    var userMessage: String
    var timeStamp: Date
    var read: Bool
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case fromUser
        case toUser
        case userMessage
        case timeStamp = "created_at"
        case read
    }
}

struct SimpleSchedule: Codable {
    var identifier: Int
    var title: String
    var description: String
    var mood: Mood
    var status: ScheduleStatus
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title = "title"
        case description = "description"
        case mood = "mood"
        case status = "status"
    }
}
