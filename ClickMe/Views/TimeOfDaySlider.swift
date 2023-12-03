//
//  TimeOfDaySlider.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-29.
//

import UIKit
import SwiftRangeSlider

class TimeOfDaySlider: RangeSlider {
    
    override func getLabelText(forValue value: Double) -> String {
        let todayStart = Date().startOfDay()
        let dateForSlider = todayStart.getPastOrFutureDate(hour: Int(value))
        return DateUtil.convert(input: dateForSlider, outputFormat: .format8)!
    }
    
}
