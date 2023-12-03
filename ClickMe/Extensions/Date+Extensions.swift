//
//  Date+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import Foundation


extension Date {
    func year(timeZone: TimeZone? = TimeZone.current) -> Int {
        var calendar = Calendar.current
        if let timezone = timeZone {
            calendar.timeZone = timezone
        }
        return calendar.component(.year, from: self)
    }
    
    func isInToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isInSameDay(date: Date, timeZone: TimeZone? = TimeZone.current) -> Bool {
        if let timeZone = timeZone {
            var calender = Calendar.current
            calender.timeZone = timeZone
            return calender.isDate(self, equalTo: date, toGranularity: .day)
        }
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    
    func hour(_ zeroIndex: Bool = false, timeZone: TimeZone = TimeZone.current) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: self) - (zeroIndex ? 1 : 0)
    }
    
    func min(_ zeroIndex: Bool = false, timeZone: TimeZone = TimeZone.current) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.minute, from: self) - (zeroIndex ? 1 : 0)
    }
    
    func startOfHour(timeZone: TimeZone? = TimeZone.current) -> Date {
        var calendar = Calendar.current
        if let timezone = timeZone {
            calendar.timeZone = timezone
        }
        var components = DateComponents()
        components.hour = calendar.component(.hour, from: self)
        components.day = calendar.component(.day, from: self)
        components.month = calendar.component(.month, from: self)
        components.year = calendar.component(.year, from: self)
        return calendar.date(from: components)!
    }
    
    func startOfDay(timeZone: TimeZone? = TimeZone.current) -> Date {
        var calendar = Calendar.current
        if let timezone = timeZone {
            calendar.timeZone = timezone
        }
        return calendar.startOfDay(for: self)
    }
    
    func startOfMonth(timeZone: TimeZone? = TimeZone.current) -> Date {
        var calendar = Calendar.current
        if let timezone = timeZone {
            calendar.timeZone = timezone
        }
        var components = DateComponents()
        components.month = calendar.component(.month, from: self)
        components.year = calendar.component(.year, from: self)
        return calendar.date(from: components)!
    }
    
    func ageToday() -> Int {
        let ageComponents = Calendar.current.dateComponents([.year], from: self, to: Date())
        let age = ageComponents.year!
        return age
    }
    
    func getPastOrFutureDate(minute: Int = 0, hour: Int = 0, days: Int = 0, months: Int = 0, years: Int = 0) -> Date {
        var components = DateComponents()
        components.minute = minute
        components.hour = hour
        components.day = days
        components.month = months
        components.year = years
        let offsetDate = Calendar.current.date(byAdding: components, to: self)!
        return offsetDate
    }
    
    func localTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func getPastOrFutureDate(sec: Int = 0, min: Int = 0, hour: Int = 0, day: Int = 0, month: Int = 0, year: Int = 0) -> Date {
        var components = DateComponents()
        components.second = sec
        components.minute = min
        components.hour = hour
        components.day = day
        components.month = month
        components.year = year
        let offsetDate = Calendar.current.date(byAdding: components, to: self)!
        return offsetDate
    }
    
    static func randomPastDate(endDate: Date = Date()) -> Date {
        let date = endDate.getPastOrFutureDate(sec: Int.random(in: 0..<60) * -1,
                                               min: Int.random(in: 0..<60) * -1,
                                               hour: Int.random(in: 0..<24) * -1,
                                               day: Int.random(in: 0...1) * -1)
        return date
    }
    
    static func randomFutureDate(startDate: Date = Date()) -> Date {
        let date = startDate.getPastOrFutureDate(sec: Int.random(in: 0..<60),
                                                 min: Int.random(in: 0..<60),
                                                 hour: Int.random(in: 0..<24),
                                                 day: Int.random(in: 0...1))
        return date
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func add(component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
}
