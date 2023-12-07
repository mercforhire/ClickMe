//
//  ExploreUserParams.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-23.
//

import Foundation
import Alamofire

struct ExploreUserParams {
    var gender: GenderChoice?
    var languages: [Language]?
    var field: UserField?

    func params() -> Parameters {
        var params: Parameters = [:]
        
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
        
        if let field = field {
            params["field"] = field.rawValue
        }
        
        return params
    }
}
