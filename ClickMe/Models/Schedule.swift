//
//  Schedule.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-27.
//

import Foundation
import UIKit

enum Mood: String, Codable {
    case startup
    case career
    case advance
    case welfare
    case pressure
    case advice
    case lifestyle
    case society
    case unknown
    
    func icon() -> UIImage {
        switch self {
        case .startup:
            return UIImage(named: "mood_startup")!
        case .career:
            return UIImage(named: "mood_career")!
        case .advance:
            return UIImage(named: "mood_advance")!
        case .welfare:
            return UIImage(named: "mood_welfare")!
        case .pressure:
            return UIImage(named: "mood_pressure")!
        case .advice:
            return UIImage(named: "mood_advice")!
        case .lifestyle:
            return UIImage(named: "mood_lifestyle")!
        case .society:
            return UIImage(named: "mood_social")!
        case .unknown:
            return UIImage(named: "field_other")!
        }
    }
    
    static func list() -> [Mood] {
        return [.startup, .career, .advance, .welfare, .pressure, .advice, .lifestyle, .society]
    }
}

extension Mood {
    init(from decoder: Decoder) throws {
        self = try Mood(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum ScheduleStatus: String, Codable {
    case open = "open"
    case pending = "pending"
    case upcoming = "upcoming"
    case started = "started"
    case finished = "finished"
    case delete = "delete"
    case unknown = "unknown"
    
    func description() -> String {
        switch self {
        case .open:
            return "Open"
        case .pending:
            return "Pending"
        case .upcoming:
            return "Upcoming"
        case .started:
            return "Started"
        case .finished:
            return "Finished"
        case .delete:
            return "Deleted"
        case .unknown:
            return "Unknown"
        }
    }
    
    func viewTitle() -> String {
        switch self {
        case .open:
            return "Open booking"
        case .pending:
            return "Booking Request"
        case .upcoming:
            return "Upcoming Booking"
        case .started:
            return "Started Booking"
        case .finished:
            return "Past Booking"
        case .delete:
            return "Deleted"
        case .unknown:
            return "Unknown"
        }
    }
    
    func labelColor() -> UIColor {
        switch self {
        case .open:
            return ThemeManager.shared.themeData!.textLabel.hexColor
        case .pending:
            return ThemeManager.shared.themeData!.gold.hexColor
        case .upcoming:
            return ThemeManager.shared.themeData!.indigo.hexColor
        case .started:
            return ThemeManager.shared.themeData!.indigo.hexColor
        case .finished:
            return ThemeManager.shared.themeData!.textLabel.hexColor
        case .delete:
            return ThemeManager.shared.themeData!.darkLabel.hexColor
        case .unknown:
            return ThemeManager.shared.themeData!.textLabel.hexColor
        }
    }
}

extension ScheduleStatus {
    init(from decoder: Decoder) throws {
        self = try ScheduleStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct Schedule: Codable {
    var identifier: Int
    var title: String
    var mood: Mood
    var coin: Int
    var myReviews: [Review]?
    var startTime: Date
    var endTime: Date
    var status: ScheduleStatus
    var description: String
    var host: ListUser
    var booker: ListUser?
    var roomId: String?
    var roomOpen: String?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title = "title"
        case mood = "mood"
        case coin = "coin"
        case myReviews = "myReviews"
        case startTime = "startTime"
        case endTime = "endTime"
        case status = "status"
        case description = "description"
        case host = "host"
        case booker = "myBooker"
        case roomId = "roomId"
        case roomOpen = "roomOpen"
    }
    
    var intradayDuration: String {
        let startTime = DateUtil.convert(input: startTime, outputFormat: .format8)
        let endTime = DateUtil.convert(input: endTime, outputFormat: .format8)
        return "\(startTime ?? "") - \(endTime ?? "")"
    }
    
    var timeAndDuration: String {
        let date = DateUtil.convert(input: startTime, outputFormat: .format11)!
        let startTime = DateUtil.convert(input: startTime, outputFormat: .format8)!
        let endTime = DateUtil.convert(input: endTime, outputFormat: .format8)!
        return "\(date), \(startTime) - \(endTime)"
    }
    
    var isSaved: Bool {
        if let favoriteSchedules = UserManager.shared.user?.favoriteSchedules, favoriteSchedules.contains(identifier) {
            return true
        }
        
        return false
    }
    
    var guestReviewed: Bool {
        for review in myReviews ?? [] {
            if review.reviewType == .asGuest {
                return true
            }
        }
        
        return false
    }
    
    var hostReviewed: Bool {
        for review in myReviews ?? [] {
            if review.reviewType == .asHost {
                return true
            }
        }
        
        return false
    }
    
    var guestReview: Review? {
        for review in myReviews ?? [] {
            if review.reviewType == .asGuest {
                return review
            }
        }
        
        return nil
    }
    
    var hostReview: Review? {
        for review in myReviews ?? [] {
            if review.reviewType == .asHost {
                return review
            }
        }
        
        return nil
    }
    
    var duration: Duration {
        let diffComponents = Calendar.current.dateComponents([.hour], from: startTime, to: endTime)
        let hours: Int = diffComponents.hour ?? 1
        return Duration(rawValue: hours) ?? .oneHour
    }
}

extension Schedule {
    func amIHost() -> Bool {
        return host.identifier == UserManager.shared.user?.identifier
    }
    
    func amIBooker() -> Bool {
        return booker?.identifier == UserManager.shared.user?.identifier
    }
}
