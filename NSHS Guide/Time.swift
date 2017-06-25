//
//  Time.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/4/26.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

struct Time:Comparable, CustomStringConvertible
{
	let hour:Int
	let minute:Int
	var description:String
	{
		let hourString:String
		//from 24HR format to 12HR format
		if (hour > 12)
		{
			hourString = String(hour - 12)
		}
		else
		{
			hourString = String(hour)
		}
		
		return String(format: "\(hourString):%02d", minute)
	}
    
    init()
    {
        let date = Date()
        let components = (Calendar.current as NSCalendar).components([.hour, .minute], from: date)
        self.hour = components.hour!
        self.minute = components.minute!
    }
	init(hour:Int, minute:Int)
	{
		self.hour = hour
		self.minute = minute
	}
	static func fromString(_ timeString:String) -> Time
	{
		let hourAndMin = timeString.components(separatedBy: ":")
		let hour = Int(hourAndMin[0])
		let min = Int(hourAndMin[1])
		
		guard hour != nil && min != nil else {
			print("Time.fromString incorrect time: \(timeString)")
			return Time(hour: 0, minute: 0)
		}
		
		return Time(hour: hour!, minute: min!)
	}
	func toMinutes() -> Int
	{
		return hour * 60 + minute;
	}
	static func fromMinutes(_ minutes:Int) -> Time
	{
		let hours = minutes / 60
		let remainingMinutes = minutes % 60
		return Time(hour: hours, minute: remainingMinutes)
	}
	static func add(startTime:Time, minutesToAdd:Int) -> Time
	{
		var timeInMinutes = startTime.toMinutes()
		timeInMinutes += minutesToAdd
		return Time.fromMinutes(timeInMinutes)
	}
	static func length(startTime:Time, endTime:Time) -> Int
	{
		let startTimeInMinutes = startTime.toMinutes()
		let endTimeInMinutes = endTime.toMinutes()
		return endTimeInMinutes - startTimeInMinutes
	}
}

//comparable methods (have to be outside of struct)
func < (lhs:Time, rhs:Time) -> Bool
{
	return lhs.toMinutes() < rhs.toMinutes()
}
func == (lhs:Time, rhs:Time) -> Bool
{
	return lhs.toMinutes() == rhs.toMinutes()
}
