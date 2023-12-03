//
//  AllDayEvent.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import JZCalendarWeekView

class ScheduleCalendarEvent: JZAllDayEvent {
    var title: String
    var cost: Int
    var editable: Bool

    init(id: String, title: String, cost: Int, startDate: Date, endDate: Date, editable: Bool) {
        self.title = title
        self.cost = cost
        self.editable = editable
        
        // If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
        super.init(id: id, startDate: startDate, endDate: endDate, isAllDay: false)
    }
    
    func conflict(other: ScheduleCalendarEvent, overrideStart: Date? = nil, overrideEnd: Date? = nil) -> Bool {
        let leftRange = ((overrideStart ?? startDate).getPastOrFutureDate(sec: 1))...((overrideEnd ?? endDate).getPastOrFutureDate(sec: -1))
        let rightRange = (other.startDate.getPastOrFutureDate(sec: 1))...(other.endDate.getPastOrFutureDate(sec: -1))
        
        return leftRange.overlaps(rightRange)
    }

    override func copy(with zone: NSZone?) -> Any {
        return ScheduleCalendarEvent(id: id, title: title, cost: cost, startDate: startDate, endDate: endDate, editable: editable)
    }
}
