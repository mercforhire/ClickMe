//
//  UpdateReviewParams.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-07-02.
//

import Foundation
import Alamofire

struct UpdateReviewParams {
    var scheduleId: Int
    var commentId: Int
    var reviewType: ReviewType
    var rating: Int
    var comment: String
    
    func params() -> Parameters {
        var params: Parameters = [:]
        params["scheduleId"] = scheduleId
        params["commentId"] = commentId
        params["reviewType"] = reviewType.rawValue
        params["rating"] = rating
        params["newComment"] = comment
        return params
    }
}
