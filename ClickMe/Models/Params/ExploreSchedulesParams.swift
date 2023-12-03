//
//  ExploreSchedulesParams.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-27.
//

import Foundation
import Alamofire

struct ExploreSchedulesParams: Codable {
    var minPrice: Int?
    var maxPrice: Int?
    var mood: Mood?
    var sortTopic: String?
    var startTime: Int = 0
    var endTime: Int = 23

    func params() -> Parameters {
        var params: Parameters = [:]
    
        if let minPrice = minPrice {
            params["coinRangeStart"] = minPrice
        }
        
        if let maxPrice = maxPrice {
            params["coinRangeEnd"] = maxPrice
        }
        
        if let mood = mood {
            params["mood"] = mood.rawValue
        }
        
        if let sortTopic = sortTopic {
            params["sortTopic"] = sortTopic
        }
        
        params["startTime"] = (24 + startTime - TimeZone.current.offsetInHours()) % 24
        params["endTime"] = (24 + endTime - TimeZone.current.offsetInHours()) % 24
        
        return params
    }
}
