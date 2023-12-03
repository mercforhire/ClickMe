//
//  ChargeNewResponse.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-11-24.
//

import Foundation

struct ChargeNewResponse: Codable {
    var publishableKey: String
    var customer: String
    var ephemeralKey: String
    var paymentIntent: String
}
