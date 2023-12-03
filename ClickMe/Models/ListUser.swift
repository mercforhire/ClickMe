//
//  SimpleUser.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-28.
//

import Foundation
import UIKit

struct ListUser: Codable {
    var identifier: Int
    var firstName: String
    var lastName: String
    var company: String
    var school: String
    var degree: String
    var jobTitle: String
    var avatar: Photo?
    var receivedLikesFrom: [Int]?
    var field: UserField?
    var photoVerify: PhotoVerificationStatus?
    var gender: GenderChoice
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case firstName = "firstName"
        case lastName = "lastName"
        case jobTitle = "jobTitle"
        case company = "company"
        case degree = "degree"
        case school = "school"
        case avatar = "avatar"
        case photoVerify = "photoVerify"
        case receivedLikesFrom = "receivedLikes"
        case field = "field"
        case gender = "gender"
    }
    
    var shortName: String {
        return "\(firstName.capitalizingFirstLetter())"
    }
    
    var fullName: String {
        return "\(firstName.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter())"
    }
    
    var jobDescription: String {
        if !jobTitle.isEmpty && !company.isEmpty {
            return "\(jobTitle) at \(company)"
        } else if jobTitle.isEmpty && !company.isEmpty {
            return jobTitle
        } else if !jobTitle.isEmpty && company.isEmpty {
            return "Works at \(company)"
        } else {
            return "Unknown occupation"
        }
    }
    
    var avatarURL: String? {
        return avatar?.smallUrl
    }
    
    var profileURL: String? {
        return avatar?.normalUrl
    }
    
    var isMyself: Bool {
        return UserManager.shared.user?.identifier == identifier
    }
    
    var defaultAvatar: UIImage {
        return gender.defaultAvatar()
    }
}
