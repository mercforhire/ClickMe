//
//  UpdateUser.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-17.
//

import Foundation
import Alamofire

struct UpdateUserParams {
    var aboutMe: String?
    var firstName: String?
    var lastName: String?
    var birthday: Date?
    var isBirthdayPublic: Bool?
    var liveAt: Location?
    var hometown: Location?
    var jobTitle: String?
    var company: String?
    var field: UserField?
    var degree: String?
    var school: String?
    var expertise: String?
    var interests: [String]?
    var lookingFor: String?
    var videoURL: String?
    var gender: GenderChoice?
    var languages: [Language]?
    var seekingRomance: Bool?
    var userPhotos: [UploadPhotoResponse]?
    var favoriteSchedules: [Int]?
    
    func params() -> Parameters {
        var params: Parameters = [:]
        
        if let aboutMe = aboutMe {
            params["aboutme"] = aboutMe
        }
        
        if let firstName = firstName {
            params["firstName"] = firstName
        }
        
        if let lastName = lastName {
            params["lastName"] = lastName
        }
        
        if let birthday = birthday {
            params["birthday"] = DateUtil.convert(input: birthday, outputFormat: .format4)
        }
        
        if let isBirthdayPublic = isBirthdayPublic {
            params["isBirthdayPublic"] = isBirthdayPublic
        }
        
        if let liveAt = liveAt {
            params["currentLocation"] = liveAt.params()
        }
        
        if let hometown = hometown {
            params["homeLocation"] = hometown.params()
        }
        
        if let jobTitle = jobTitle {
            params["jobTitle"] = jobTitle
        }
        
        if let company = company {
            params["company"] = company
        }
        
        if let field = field {
            params["field"] = field.rawValue
        }
        
        if let degree = degree {
            params["degree"] = degree
        }
        
        if let school = school {
            params["school"] = school
        }
        
        if let expertise = expertise {
            params["expertise"] = expertise
        }
        
        if let interests = interests {
            params["interests"] = interests
        }
        
        if let lookingFor = lookingFor {
            params["lookingFor"] = lookingFor
        }
        
        if let videoURL = videoURL {
            params["videoUrl"] = videoURL
        }
        
        if let gender = gender {
            params["gender"] = gender.rawValue
        }
        
        if let languages = languages {
            var languagesArray: [String] = []
            for language in languages {
                languagesArray.append(language.rawValue)
            }
            params["languages"] = languagesArray
        }
        
        if let seekingRomance = seekingRomance {
            params["seekingRomance"] = seekingRomance
        }
        
        if let userPhotos = userPhotos {
            var userPhotosArray: [Parameters] = []
            for userPhoto in userPhotos {
                userPhotosArray.append(userPhoto.params())
            }
            params["userPhotos"] = userPhotosArray
        }
        
        if let favoriteSchedules = favoriteSchedules {
            params["favoriteSchedules"] = favoriteSchedules
        }
        
        return params
    }
}
