//
//  RTCTokenResponse.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-08-17.
//

import Foundation

//{
//    "RTCToken": "0065ccb9d5f8b7f40f8a704ee0a73bb6735IADtx0NAm6xfOxyqDPBnC2ZDXZmjF0UmcTpmomVUbVvMoy3xAZ/VIt+BIgB7LNM8fH8cYQQAAQB8fxxhAgB8fxxhAwB8fxxhBAB8fxxh"
//}

struct RTCTokenResponse: Codable {
    var RTCToken: String
    
    enum CodingKeys: String, CodingKey {
        case RTCToken = "RTCToken"
    }
}
