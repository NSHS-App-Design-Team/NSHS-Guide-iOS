//
//  AbsentTeacherCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/2/8.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class AbsentTeacherCell:AbsentTeacherNoInfoCell
{
	@IBOutlet private var extraInfo: UILabel!
	
	override func configure(teacher:TeacherOtherAbsent, blocks:[Block])
	{
		super.configure(teacher: teacher, blocks: blocks)
		extraInfo.text = teacher.info
	}
}
