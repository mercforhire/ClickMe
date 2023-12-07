//
//  PublicUserData.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-17.
//

import Foundation
import UIKit

struct PublicUser: Codable {
    var identifier: Int
    var screenId: String?
    var firstName: String
    var lastName: String
    var birthday: Date?
    var isBirthdayPublic: Bool
    var liveAt: Location?
    var hometown: Location?
    var jobTitle: String
    var company: String
    var field: UserField?
    var degree: String
    var school: String
    var aboutMe: String
    var expertise: String?
    var interests: [String]?
    var lookingFor: String
    var photos: [Photo]?
    var likes: [Int]?
    var receivedLikesFrom: [Int]?
    var following: [Int]?
    var followers: [Int]?
    var videoURL: String?
    var gender: GenderChoice
    var languages: [Language]?
    var photoVerify: PhotoVerificationStatus?
    var hostTotal: Int
    var hostCount: Int
    var guestTotal: Int
    var guestCount: Int
    var totalHostHours: Int
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case screenId = "screenId"
        case firstName = "firstName"
        case lastName = "lastName"
        case birthday = "birthday"
        case isBirthdayPublic = "isBirthdayPublic"
        case hometown = "homeLocation"
        case liveAt = "currentLocation"
        case jobTitle = "jobTitle"
        case company = "company"
        case field = "field"
        case degree = "degree"
        case school = "school"
        case aboutMe = "aboutme"
        case expertise = "expertise"
        case interests = "interests"
        case lookingFor = "lookingFor"
        case photos = "photos"
        case likes = "likes"
        case following = "followeeList"
        case followers = "followerList"
        case videoURL = "videoUrl"
        case gender = "gender"
        case languages = "languages"
        case receivedLikesFrom = "receivedLikes"
        case photoVerify = "photoVerify"
        case hostTotal
        case hostCount
        case guestTotal
        case guestCount
        case totalHostHours
    }
    
    var birthdayString: String {
        if let birthday = birthday {
            return DateUtil.convert(input: birthday, outputFormat: .format14)!
        } else {
            return "Private"
        }
    }
    
    var age: Int? {
        if let birthday = birthday {
            return birthday.ageToday()
        }
        return nil
    }
    
    var fullName: String {
        return "\(firstName.capitalizingFirstLetter()) \(lastName.capitalizingFirstLetter())"
    }
    
    var fullNameAndAge: String {
        if let age = age {
            return "\(fullName), \(age)"
        } else {
            return fullName
        }
    }
    
    var jobDescription: String {
        if !jobTitle.isEmpty && !company.isEmpty {
            return "\(jobTitle) at \(company)"
        } else if jobTitle.isEmpty && !company.isEmpty {
            return jobTitle
        } else if !jobTitle.isEmpty && company.isEmpty {
            return "Works at \(company)"
        } else {
            return ""
        }
    }
    
    var avatarURL: String? {
        return photos?.first?.smallUrl
    }
    
    var profileURL: String? {
        return photos?.first?.normalUrl
    }
    
    var score: Double {
        return (Double(hostTotal) + Double(guestTotal)) / (Double(hostCount) + Double(guestCount))
    }
    
    var ratingString: String {
        if (hostCount + guestCount) > 0 {
            return String(format: "%.1f", score)
        }
        
        return "--"
    }
    
    func toSimpleUser() -> ListUser {
        return ListUser(identifier: identifier, firstName: firstName, lastName: lastName, company: company, school: school, degree: degree, jobTitle: jobTitle, avatar: photos?.first, photoVerify: photoVerify, gender: gender)
    }
    
    var isMyself: Bool {
        return UserManager.shared.user?.identifier == identifier
    }
    
    var defaultAvatar: UIImage {
        return gender.defaultAvatar()
    }
}
