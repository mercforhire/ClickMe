//
//  CompleteUser.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-24.
//

import Foundation
import UIKit

class CompleteUser: Codable {
    var identifier: Int
    var screenId: String
    var email: String?
    var areaCode: String?
    var phone: String?
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
    var verified: Bool
    var videoURL: String?
    var videoThumbnailUrl: String?
    var gender: GenderChoice
    var languages: [Language]?
    var seekingRomance: Bool
    var favoriteSchedules: [Int]?
    var blockedUsers: [Int]?
    var photoVerify: PhotoVerificationStatus?
    var cancelCounter: Int?
    var wallet: Wallet?
    var hostTotal: Int
    var hostSize: Int
    var guestTotal: Int
    var guestSize: Int
    var totalHostHours: Int
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case screenId = "screenId"
        case email = "email"
        case areaCode = "areaCode"
        case phone = "phone"
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
        case verified = "verify"
        case videoURL = "videoUrl"
        case videoThumbnailUrl = "videoThumbnailUrl"
        case gender = "gender"
        case languages = "languages"
        case seekingRomance = "seekingRomance"
        case receivedLikesFrom = "receivedLikes"
        case favoriteSchedules = "favoriteSchedules"
        case blockedUsers = "blockUsers"
        case photoVerify = "photoVerify"
        case cancelCounter = "cancelCounter"
        case wallet = "myCoins"
        case hostTotal
        case hostSize
        case guestTotal
        case guestSize
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
    
    var guestScore: Double {
        return Double(guestTotal) / Double(guestSize)
    }
    
    var guestRatingString: String {
        if guestTotal > 0, guestSize > 0 {
            return String(format: "%.1f", guestScore)
        }
        
        return "--"
    }
    
    var hostScore: Double {
        return Double(hostTotal) / Double(hostSize)
    }
    
    var hostRatingString: String {
        if hostTotal > 0, hostSize > 0 {
            return String(format: "%.1f", hostScore)
        }
        
        return "--"
    }
    
    var interestsString: String {
        guard let interests = interests else { return "" }
        
        var string: String = ""
        for interest in interests {
            string = string.isEmpty ? "#\(interest)" : "\(string) #\(interest)"
        }
        return string
    }
    
    var phoneNumber: String {
        if let phone = phone {
            if let areaCode = areaCode {
                return "+\(areaCode)\(phone)"
            }
            return "\(phone)"
        } else {
            return "No phone number"
        }
    }
    
    var publicUser: PublicUser {
        let publicUser = PublicUser(identifier: identifier, screenId: screenId, firstName: firstName, lastName: lastName, birthday: birthday, isBirthdayPublic: isBirthdayPublic, liveAt: liveAt, hometown: hometown, jobTitle: jobTitle, company: company, field: field, degree: degree, school: school, aboutMe: aboutMe, expertise: expertise, interests: interests, lookingFor: lookingFor, photos: photos, likes: likes, receivedLikesFrom: receivedLikesFrom, following: following, followers: followers, videoURL: videoURL, gender: gender, languages: languages, seekingRomance: seekingRomance, photoVerify: photoVerify, hostTotal: hostTotal, hostCount: hostSize, guestTotal: guestTotal, guestCount: guestSize, totalHostHours: totalHostHours)
        return publicUser
    }
    
    func getUploadPhotoResponseArray() -> [UploadPhotoResponse] {
        var resultPhotos: [UploadPhotoResponse] = []
        for photo in photos ?? [] {
            resultPhotos.append(photo.toUploadPhotoResponse())
        }
        return resultPhotos
    }
    
    func updateUser(params: UpdateUserParams) {
        if let aboutMe = params.aboutMe {
            self.aboutMe = aboutMe
        }
        
        if let firstName = params.firstName {
            self.firstName = firstName
        }
        
        if let lastName = params.lastName {
            self.lastName = lastName
        }
        
        if let birthday = params.birthday {
            self.birthday = birthday
        }
        
        if let isBirthdayPublic = params.isBirthdayPublic {
            self.isBirthdayPublic = isBirthdayPublic
        }
        
        if let liveAt = params.liveAt {
            self.liveAt = liveAt
        }
        
        if let hometown = params.hometown {
            self.hometown = hometown
        }
        
        if let jobTitle = params.jobTitle {
            self.jobTitle = jobTitle
        }
        
        if let company = params.company {
            self.company = company
        }
        
        if let field = params.field {
            self.field = field
        }
        
        if let degree = params.degree {
            self.degree = degree
        }
        
        if let school = params.school {
            self.school = school
        }
        
        if let expertise = params.expertise {
            self.expertise = expertise
        }
        
        if let interests = params.interests {
            self.interests = interests
        }
        
        if let lookingFor = params.lookingFor {
            self.lookingFor = lookingFor
        }
        
        if let videoURL = params.videoURL {
            self.videoURL = videoURL
        }
        
        if let gender = params.gender {
            self.gender = gender
        }
        
        if let languages = params.languages {
            self.languages = languages
        }
        
        if let seekingRomance = params.seekingRomance {
            self.seekingRomance = seekingRomance
        }
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
