//
//  YourTeacherCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/11/14.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class YourTeacherCell:YourTeacherNoSubjectCell
{
	@IBOutlet private var subjectText:UILabel!
	
	override func configure(teacher: TeacherYours)
	{
		super.configure(teacher: teacher)
		subjectText.text = teacher.subject
	}
}
