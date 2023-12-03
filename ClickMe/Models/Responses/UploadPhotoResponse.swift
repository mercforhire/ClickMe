//
//  UploadPhotoResponse.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-23.
//

import Foundation
import Alamofire

struct UploadPhotoResponse: Codable {
    var smallUrl: String
    var normalUrl: String
    
    enum CodingKeys: String, CodingKey {
        case smallUrl = "smallImageUrl"
        case normalUrl = "normalImageUrl"
    }
    
    func params() -> Parameters {
        var params: Parameters = [:]
        params["smallImageUrl"] = smallUrl
        params["normalImageUrl"] = normalUrl
        return params
    }
}

struct UploadVideoResponse: Codable {
    var videoUrl: String
    var videoThumbnail: String
    
    enum CodingKeys: String, CodingKey {
        case videoUrl = "videoUrl"
        case videoThumbnail = "videoThumbnail"
    }
    
    func params() -> Parameters {
        var params: Parameters = [:]
        params["videoUrl"] = videoUrl
        params["videoThumbnail"] = videoThumbnail
        return params
    }
}
