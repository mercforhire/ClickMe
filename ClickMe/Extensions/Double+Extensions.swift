//
//  Double+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-08-31.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
