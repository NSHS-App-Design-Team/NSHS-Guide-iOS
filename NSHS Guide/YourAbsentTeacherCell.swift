//
//  YourAbsentTeacherCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/3/29.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class YourAbsentTeacherCell:YourAbsentTeacherNoInfoCell
{
	@IBOutlet private var extraInfo: UILabel!
	
	override func configure(teacher:TeacherYourAbsent)
	{
		super.configure(teacher: teacher)
		extraInfo.text = teacher.info
	}
}
