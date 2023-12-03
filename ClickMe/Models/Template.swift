//
//  Template.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-06.
//

import Foundation
import UIKit

struct Template: Codable {
    var identifier: Int
    var title: String
    var mood: Mood
    var description: String
    var coin: Int
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title = "title"
        case mood = "mood"
        case coin = "coin"
        case description = "description"
    }
}
