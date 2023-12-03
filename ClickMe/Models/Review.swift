//
//  Review.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-17.
//

import Foundation

enum ReviewType: String, Codable {
    case asGuest = "asGuest"
    case asHost = "asHost"
}

struct Review: Codable {
    var identifier: Int
    var body: String?
    var rating: Int
    var reviewType: ReviewType
    var writer: ListUser
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case body = "newComment"
        case rating = "rating"
        case reviewType = "reviewType"
        case writer = "writer"
    }
}
