//
//  BlockMonthDelegate.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2016/6/10.
//  Copyright © 2016年 NSHS App Design Team. All rights reserved.
//

import UIKit
import JTCalendar

class BlockMonthDelegate:NSObject, JTCalendarDelegate
{
    private var selectedDate = LocalDate()
    private let selectedDateChangeFunc:(LocalDate) -> ()
    
    init(selectedDateChangeFunc:@escaping (LocalDate) -> ())
    {
        self.selectedDateChangeFunc = selectedDateChangeFunc
    }
    func calendar(_ calendar: JTCalendarManager!, prepareDayView uiDayView: UIView!)
    {
        let dayView = uiDayView as! JTCalendarDayView
        let date = LocalDate(date: dayView.date)
        let scheduleType = Settings.getScheduleType(for: date)
        
        setDayViewTextColor(dayView, date: date, scheduleType: scheduleType)
        setDayViewDotColor(dayView, scheduleType: scheduleType)
        setDayViewCircleColor(dayView, date: date)
    }
    func calendar(_ calendar: JTCalendarManager!, didTouchDayView uiDayView: UIView!)
    {
        let dayView = uiDayView as! JTCalendarDayView
        guard dateIsInRange(dayView.date) else {
            return
        }
        selectedDate = LocalDate(date: dayView.date)
        selectedDateChangeFunc(selectedDate)
        calendar.reload()
    }
    //make month text white
    func calendarBuildMenuItemView(_ calendar: JTCalendarManager!) -> UIView!
    {
        let menuItemView = UILabel()
        menuItemView.textAlignment = .center
        menuItemView.textColor = UIColor.white
        return menuItemView
    }
    func calendar(_ calendar: JTCalendarManager!, canDisplayPageWith nsDate: Date!) -> Bool
    {
        return dateIsInRange(nsDate)
    }
    
    private func setDayViewTextColor(_ dayView:JTCalendarDayView, date:LocalDate, scheduleType:ScheduleType)
    {
        if (scheduleType == .special)
        {
            dayView.textLabel.textColor = AppColors.amber.uicolor()
        }
        else if (dayView.isFromAnotherMonth || !date.isWeekday() || scheduleType == .noSchool)
        {
            dayView.textLabel.textColor = UIColor.lightGray
        }
        else
        {
            dayView.textLabel.textColor = UIColor.white
        }
    }
    private func setDayViewDotColor(_ dayView:JTCalendarDayView, scheduleType:ScheduleType)
    {
        switch (scheduleType)
        {
        case .special:
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = AppColors.amber.uicolor()
        case .noSchool:
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = UIColor.lightGray
        case .normal:
            dayView.dotView.isHidden = true
        }
    }
    private func setDayViewCircleColor(_ dayView:JTCalendarDayView, date:LocalDate)
    {
        if (date == selectedDate)
        {
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = AppColors.accent.uicolor()
        }
        else
        {
            dayView.circleView.isHidden = true
        }
    }
    private func dateIsInRange(_ nsDate:Date) -> Bool
    {
        let date = LocalDate(date: nsDate)
        return date >= SchoolYear.start && date <= SchoolYear.end
    }
}
