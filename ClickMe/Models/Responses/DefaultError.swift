//
//  DefaultError.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-12.
//

import Foundation

struct DefaultError: Codable {
    var error: String?
    
    init(dict: [String: Any]) {
        error = dict["error"] as? String
    }
}
