//
//  LocalDate.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/17.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

/**
 Days of the week with corresponding numbers, starting with sunday as 1, ending with saturday as 7. A static `WEEKDAYS` array is provided with only the weekdays included, in order.
 */
enum DayOfWeek:Int
{
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    static let WEEKDAYS = [monday, tuesday, wednesday, thursday, friday]
}
/**
 In order to simplify the disgustinly convoluted Date + Calendar + DateComponents set up Swift has in place for us, this class was created, based on Java 8's immutable LocalDate class.
 */
struct LocalDate:Hashable, Comparable, CustomStringConvertible
{
    static let dateManipulater = Calendar.current
    static let components:Set<Calendar.Component> = [.year, .month, .day, .weekday, .weekOfYear]
    private let date:Date
    private var dateComponents:DateComponents	//computed property as it needs to update dynamically with date
    {
        get
        {
            return LocalDate.dateManipulater.dateComponents(LocalDate.components, from: date)
        }
    }
    
    //make sure second & nanosecond are both 0 in all initializations just in case we use NSDate.compare() on 2 localDates
    init()
    {
        date = LocalDate.dateWithoutHourMinuteSeconds(Date())
    }
    init(date:Date)
    {
        self.date = LocalDate.dateWithoutHourMinuteSeconds(date)
    }
    init(year:Int, month:Int, day:Int)
    {
        var dateComponents = LocalDate.dateManipulater.dateComponents(LocalDate.components, from: Date())
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        let dateWithHourMinuteSeconds = LocalDate.dateManipulater.date(from: dateComponents)!
        date = LocalDate.dateWithoutHourMinuteSeconds(dateWithHourMinuteSeconds)
    }
    private static func dateWithoutHourMinuteSeconds(_ date:Date) -> Date
    {
        let dateComponents = LocalDate.dateManipulater.dateComponents(LocalDate.components, from: date)
        return LocalDate.dateManipulater.date(from: dateComponents)!
    }
    func add(_ value:Int, forType type:Calendar.Component) -> LocalDate
    {
        guard let newDate = LocalDate.dateManipulater.date(byAdding: type, value: value, to: date) else {
            Internet.sendErrorMessage("LocalDate.add() failed, help")
            return self
        }
        return LocalDate(date: newDate)
    }
    func set(_ value:Int, forType type:Calendar.Component) -> LocalDate
    {
        //NOTE: doesn't use dateBySettingUnit although that is easier because that's not supported by iOS 7 (and because that does random ass things on iOS 8)
        var dateComponents = LocalDate.dateManipulater.dateComponents(LocalDate.components, from: date)
        switch (type)
        {
        case .day:
            dateComponents.day = value
        case .weekOfYear:
            dateComponents.weekOfYear = value
        case .month:
            dateComponents.month = value
        case .weekday:
            return setWeekday(value)
        case .year:
            dateComponents.year = value
        default:
            print("LocalDate.set() called with invalid type: \(type)")
        }
        let newDate = LocalDate.dateManipulater.date(from: dateComponents)!
        return LocalDate(date: newDate)
    }
    //alternative way to set dayOfWeek for better practice (uses constants)
    func setDayOfWeek(_ dayOfWeek:DayOfWeek) -> LocalDate
    {
        return setWeekday(dayOfWeek.rawValue)
    }
    func get(_ type:Calendar.Component) -> Int
    {
        switch (type)
        {
        case .day:
            return dateComponents.day!
        case .weekOfYear:
            return dateComponents.weekOfYear!
        case .month:
            return dateComponents.month!
        case .weekday:
            return dateComponents.weekday!
        case .year:
            return dateComponents.year!
        default:
            print("LocalDate.get() called with invalid type: \(type)")
            return 0
        }
    }
    func getDaysInMonth() -> Int
    {
        return LocalDate.dateManipulater.range(of: .day, in: .month, for: date)!.count
    }
    func getFirstLastWeeksInMonth() -> (firstWeek:LocalDate, lastWeek:LocalDate)
    {
        let firstDay = set(1, forType: .day)
        let lastDay = set(getDaysInMonth(), forType: .day)
        return (firstDay, lastDay)
    }
    func getDayOfWeek() -> DayOfWeek
    {
        return DayOfWeek(rawValue: get(.weekday))!
    }
    func getDayOfYear() -> Int
    {
        return LocalDate.dateManipulater.ordinality(of: .day, in: .year, for: date)!
    }
    func isWeekday() -> Bool
    {
        let dayOfWeek = get(.weekday)
        return dayOfWeek != DayOfWeek.saturday.rawValue && dayOfWeek != DayOfWeek.sunday.rawValue
    }
    func isToday() -> Bool
    {
        return LocalDate() == self
    }
    func format(_ format:String) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //directly setting weekday does not affect the actual day, thus this workaround is necessary
    private func setWeekday(_ newWeekday:Int) -> LocalDate
    {
        let difference = newWeekday - dateComponents.weekday!
        let newDate = LocalDate.dateManipulater.date(byAdding: .day, value: difference, to: date)!
        return LocalDate(date: newDate)
    }
    
    var hashValue: Int { return date.hashValue }
    var description: String { return "\(get(.month))/\(get(.day))/\(get(.year))"}
}
func == (lhs:LocalDate, rhs:LocalDate) -> Bool
{
    return lhs.get(.day) == rhs.get(.day) && lhs.get(.month) == rhs.get(.month) && lhs.get(.year) == rhs.get(.year)
}
func < (lhs:LocalDate, rhs:LocalDate) -> Bool
{
    let leftYear = lhs.get(.year)
    let rightYear = rhs.get(.year)
    if (leftYear < rightYear)
    {
        return true
    }
    else if (leftYear == rightYear)
    {
        let leftMonth = lhs.get(.month)
        let rightMonth = rhs.get(.month)
        if (leftMonth < rightMonth)
        {
            return true
        }
        else if (leftMonth == rightMonth)
        {
            if (lhs.get(.day) < rhs.get(.day))
            {
                return true
            }
        }
    }
    return false
}
