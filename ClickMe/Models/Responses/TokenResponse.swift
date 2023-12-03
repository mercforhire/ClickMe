//
//  TokenResponse.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-19.
//

import Foundation

struct TokenResponse: Codable {
    var token: String
    var refreshToken: String
    
    init(dict: [String: Any]) {
        token = dict["token"] as? String ?? ""
        refreshToken = dict["refreshToken"] as? String ?? ""
    }
}
