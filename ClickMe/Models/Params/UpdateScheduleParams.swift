//
//  UpdateScheduleParams.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-28.
//

import Foundation
import Alamofire

struct UpdateScheduleParams: Codable {
    var identifier: Int
    var title: String
    var mood: Mood
    var coin: Int
    var startTime: Date
    var endTime: Date
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title = "title"
        case mood = "mood"
        case coin = "coin"
        case startTime = "startTime"
        case endTime = "endTime"
        case description = "description"
    }
    
    func params() -> Parameters {
        var params: Parameters = [:]
        
        params["id"] = identifier
        params["title"] = title
        params["mood"] = mood.rawValue
        params["coin"] = coin
        params["startTime"] = "\(DateUtil.convert(input: startTime, outputFormat: .format2, timeZone: TimeZone(abbreviation: "UTC")!)!).000Z"
        params["endTime"] = "\(DateUtil.convert(input: endTime, outputFormat: .format2, timeZone: TimeZone(abbreviation: "UTC")!) ?? "").000Z"
        params["description"] = description
        
        return params
    }
}
