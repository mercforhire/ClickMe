//
//  File.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-01.
//

import Foundation
import UIKit

struct Photo: Codable {
    var identifier: Int
    var index: Int
    var normalUrl: String
    var smallUrl: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case index = "index"
        case normalUrl = "normalImageUrl"
        case smallUrl = "smallImageUrl"
    }
    
    func toUploadPhotoResponse() -> UploadPhotoResponse {
        return UploadPhotoResponse(smallUrl: smallUrl, normalUrl: normalUrl)
    }
}
