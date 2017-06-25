//
//  LayoutConstants.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/11/13.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 This class stores often used values in determining layout sizes in one place so that changing the value in this location will affect all on-screen elements which use this enum.
 */
enum LayoutConstants:CGFloat
{
	case margin = 16
	case blockImageSize = 50
	case listOneLineNoImageHeight = 48
	case listOneLineHeight = 56
	case listTwoLineHeight = 72
	case listThreeLineHeight = 88
	case listImageSize = 40
	case calendarPickerHeight = 60
	case calendarPickerItemWidth = 90
	case calendarPickerItemPadding = 12
	case calendarPickerSelectionHeight = 2
	case blockMonthItemPadding = 8
}
