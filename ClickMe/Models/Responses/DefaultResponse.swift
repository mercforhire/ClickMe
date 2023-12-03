//
//  DefaultResponse.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-12.
//

import Foundation

struct DefaultResponse: Codable {
    var message: String?
    var error: String?
    
    init(dict: [String: Any]) {
        message = dict["message"] as? String
        error = dict["error"] as? String
    }
}
