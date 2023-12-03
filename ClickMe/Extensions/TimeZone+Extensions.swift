//
//  TimeZone+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-07-16.
//

import Foundation

extension TimeZone {
    func offsetInHours() -> Int {
        let hours = secondsFromGMT() / 3600
        return hours
    }
}
