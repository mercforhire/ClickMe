//
//  Geolocation.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-23.
//

import Foundation

struct Geolocation: Codable {
    var lat: Double = 0.0
    var long: Double = 0.0
    
    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case long = "lon"
    }
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        
        params["lat"] = lat
        params["long"] = long
        
        return params
    }
}
