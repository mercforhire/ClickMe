//
//  CreateReviewParams.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-07-02.
//

import Foundation
import Alamofire

struct CreateReviewParams {
    var scheduleId: Int
    var reviewType: ReviewType
    var rating: Double
    var comment: String
    
    func params() -> Parameters {
        var params: Parameters = [:]
        params["scheduleId"] = scheduleId
        params["reviewType"] = reviewType.rawValue
        params["rating"] = rating
        params["newComment"] = comment
        return params
    }
}
