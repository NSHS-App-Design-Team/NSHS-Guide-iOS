//
//  SchoolYear.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/8/9.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

/**
 Calculates and stores the dates for the beginning and end of the school year, with the correct year. For example, if today were 1/1/2017, the start of the school year would be 9/1/2016 and the end would be 8/31/2017.
 */
class SchoolYear
{
    static let start = SchoolYear.getStart()
    static let end = SchoolYear.getEnd()
	private init(){}
    
    /**
     Returns the beginning of the school year, assuming it starts on 9/1
     */
    private static func getStart() -> LocalDate
	{
        let today = LocalDate()
        if (today.get(.month) < 9)
        {
            return LocalDate(year: today.get(.year) - 1, month: 9, day: 1)
        }
        else
        {
            return LocalDate(year: today.get(.year), month: 9, day: 1)
        }
	}
    /**
     Returns the end of the school year, assuming it ends on 8/31
     */
	private static func getEnd() -> LocalDate
	{
        let today = LocalDate()
        if (today.get(.month) < 9)
        {
            return LocalDate(year: today.get(.year), month: 8, day: 31)
        }
        else
        {
            return LocalDate(year: today.get(.year) + 1, month: 8, day: 31)
        }
	}
}
