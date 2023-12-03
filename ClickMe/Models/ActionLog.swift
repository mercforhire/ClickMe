//
//  ActionLog.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-08-27.
//

import Foundation

enum ActionType: String, Codable {
    case create
    case update
    case delete
    case open
    case pending
    case upcoming
    case finished
    case tips
    case hostCancel
    case guestCancel
    case deny
    case approve
    case unknown
}

extension ActionType {
    init(from decoder: Decoder) throws {
        self = try ActionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct ActionLog: Codable, ItemWithTimeStamp {
    var identifier: Int
    var action: ActionType
    var fromUser: ListUser?
    var toUser: ListUser?
    var thisSchedule: Schedule?
    var timeStamp: Date

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case action
        case fromUser
        case toUser
        case thisSchedule
        case timeStamp = "createdTimestamp"
    }
    
    func getTimeStamp() -> Date {
        return timeStamp
    }
    
    func logDescription() -> String {
        switch action {
        case .approve:
            return "\(fromUser?.shortName  ?? "") approved \(toUser?.shortName ?? "")'s booking request for \(thisSchedule?.title ?? "")"
        case .deny:
            return "\(fromUser?.shortName  ?? "") rejected \(toUser?.shortName ?? "")'s booking request for \(thisSchedule?.title ?? "")"
        case .pending:
            return "\(fromUser?.shortName  ?? "") sent a booking request for \(thisSchedule?.title ?? "")"
        case .guestCancel:
            return "\(fromUser?.shortName  ?? "") cancelled the session: \(thisSchedule?.title ?? "")"
        case .hostCancel:
            return "\(fromUser?.shortName  ?? "") cancelled the session: \(thisSchedule?.title ?? "")"
        case .tips:
            return "\(fromUser?.shortName  ?? "") gave \(toUser?.shortName ?? "") some coins as tip"
        default:
            break
        }
        
        return ""
    }
}
