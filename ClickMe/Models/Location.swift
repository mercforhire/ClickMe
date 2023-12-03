//
//  Location.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-18.
//

import Foundation
import CoreLocation

struct Location: Codable {
    var city: String
    var state: String
    var country: String
    var latitude: Double
    var longitude: Double
    var locationString: String? {
        if !city.isEmpty, !state.isEmpty {
            return "\(city), \(state)"
        } else if !city.isEmpty {
            return "\(city)"
        } else if !state.isEmpty {
            return "\(state)"
        }
        
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case city = "city"
        case state = "province"
        case country = "country"
        case latitude = "lat"
        case longitude = "lon"
    }
    
    static func random() -> Location {
        return Location(city: Lorem.words(Int.random(in: 1...2)),
                        state: Lorem.words(Int.random(in: 1...2)),
                        country: Lorem.words(Int.random(in: 1...2)),
                        latitude: Double.random(in: -90...90),
                        longitude: Double.random(in: -180...180))
    }
    
    init(city: String, state: String, country: String, latitude: Double, longitude: Double) {
        self.city = city
        self.state = state
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(placemark: CLPlacemark) {
        self.city = placemark.city ?? ""
        self.state = placemark.state ?? ""
        self.country = placemark.country ?? ""
        self.latitude = placemark.location?.coordinate.latitude ?? 0.0
        self.longitude = placemark.location?.coordinate.longitude ?? 0.0
    }
    
    func params() -> [String: String] {
        var params: [String: String] = [:]
        
        params["city"] = city
        params["country"] = country
        params["lat"] = "\(String(format: "%.6f", latitude))"
        params["lon"] = "\(String(format: "%.6f", longitude))"
        params["province"] = state
        
        return params
    }
}
