//
//  ExploreSchedulesResponse.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-27.
//

import Foundation

struct ExploreSchedulesResponse: Codable {
    var content: [Schedule]
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
