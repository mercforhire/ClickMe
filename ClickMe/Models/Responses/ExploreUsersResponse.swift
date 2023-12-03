//
//  ExploreUsersResponse.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-23.
//

import Foundation

struct ExploreUsersResponse: Codable {
    var content: [ListUser]
    var totalPages: Int
    var totalElements: Int
    var pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
        case totalPages = "totalPages"
        case totalElements = "totalElements"
        case pageSize = "size"
    }
}
