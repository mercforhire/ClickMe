//
//  ExploreUserParams.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-23.
//

import Foundation
import Alamofire

struct ExploreUserParams {
    var currentPage: Int?
    var distance: Int = 1001
    var gender: GenderChoice?
    var geolocation: Geolocation = Geolocation()
    var languages: [Language]?
    var pageSize: Int?
    var seekingRomance: Bool?
    var field: UserField?

    func params() -> Parameters {
        var params: Parameters = [:]
        
        if let currentPage = currentPage {
            params["currentPage"] = currentPage
        }
        
        params["distance"] = distance
        
        if let gender = gender {
            params["gender"] = gender.rawValue
        }
        
        params["geolocation"] = geolocation.params()
        
        if let languages = languages {
            var languagesArray: [String] = []
            for language in languages {
                languagesArray.append(language.rawValue)
            }
            params["languages"] = languagesArray
        }
        
        if let pageSize = pageSize {
            params["pageSize"] = pageSize
        }
        
        params["seekingRomance"] = seekingRomance ?? false
        
        if let field = field {
            params["field"] = field.rawValue
        }
        
        return params
    }
}
