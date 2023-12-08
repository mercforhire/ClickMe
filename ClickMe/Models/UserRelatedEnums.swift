//
//  UserRelatedEnums.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-24.
//

import Foundation
import UIKit

enum GenderChoice: String, Codable {
    case male = "man"
    case female = "woman"
    case other = "other"
    case unknown = "unknown"
    
    func label() -> String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        default:
            return "Unknown"
        }
    }
    
    func defaultAvatar() -> UIImage {
        switch self {
        case .male:
            return UIImage(named: "male-l")!
        case .female:
            return UIImage(named: "female-l")!
        default:
            return UIImage(named: "other-l")!
        }
    }
    
    static func random() -> GenderChoice {
        switch Int.random(in: 0...3) {
        case 0:
            return .male
        case 1:
            return .female
        case 2:
            return .other
        case 3:
            return .unknown
        default:
            return .unknown
        }
    }
    
    static func genderFrom(index: Int) -> GenderChoice {
        switch index {
        case 0:
            return .male
        case 1:
            return .female
        case 2:
            return .other
        default:
            return .unknown
        }
    }
    
    static func list() -> [GenderChoice] {
        return [.male, .female, .other]
    }
}

extension GenderChoice {
    init(from decoder: Decoder) throws {
        self = try GenderChoice(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum Language: String, Codable {
    case english = "english"
    case chinese = "chinese"
    case spanish = "spanish"
    case french = "french"
    case tagalog = "tagalog"
    case vietnamese = "vietnamese"
    case german = "german"
    case arabic = "arabic"
    case korean = "korean"
    
    static func random() -> Language {
        switch Int.random(in: 0...8) {
        case 0:
            return .english
        case 1:
            return .chinese
        case 2:
            return .spanish
        case 3:
            return .french
        case 4:
            return .tagalog
        case 5:
            return .vietnamese
        case 6:
            return .german
        case 7:
            return .arabic
        case 8:
            return .korean
        default:
            return .english
        }
    }
    
    static func list() -> [Language] {
        return [.english, .chinese, .spanish, .french, .tagalog, .vietnamese, .german, .arabic, .korean]
    }
}

enum UserField: String, Codable {
    case business
    case social
    case tech
    case entertainment
    case education
    case media
    case science
    case others
    case unknown
    
    func icon() -> UIImage {
        switch self {
        case .business:
            return UIImage(named: "field_business")!
        case .social:
            return UIImage(named: "field_social")!
        case .tech:
            return UIImage(named: "field_tech")!
        case .entertainment:
            return UIImage(named: "field_entertainment")!
        case .education:
            return UIImage(named: "field_education")!
        case .media:
            return UIImage(named: "field_media")!
        case .science:
            return UIImage(named: "field_science")!
        case .others:
            return UIImage(named: "field_other")!
        default:
            return UIImage(named: "field_other")!
        }
    }
    
    static func list() -> [UserField] {
        return [.business, .social, .tech, .entertainment, .education, .media, .science, .others]
    }
}

extension UserField {
    init(from decoder: Decoder) throws {
        self = try UserField(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
