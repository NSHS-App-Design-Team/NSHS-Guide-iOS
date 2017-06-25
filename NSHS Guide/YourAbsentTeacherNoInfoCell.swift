//
//  YourAbsentTeacherNoInfoCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/24.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class YourAbsentTeacherNoInfoCell:UITableViewCell
{
	@IBOutlet private var blockImage: UITextField!
	@IBOutlet private var teacherName: UILabel!
	@IBOutlet private var time: UILabel!
	
	override func awakeFromNib()
	{
		//random bug causes blockImage to be nil when only announcement is showing
		guard blockImage != nil else {
			print("blockImage nil")
			return
		}
		Cell.round(blockImage)
	}
	func configure(teacher:TeacherYourAbsent)
	{
		blockImage.text = teacher.block.letter
		time.text = teacher.block.getTimeString()
		time.sizeToFitRight()
		teacherName.text = teacher.name
		
        Cell.color(accordingTo: blockImage.text!, colorType: .normal, view: blockImage)
	}
}
