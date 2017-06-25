//
//  YourTeacherCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/2/12.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class YourTeacherNoSubjectCell:UITableViewCell
{
	@IBOutlet private var teacherName: UILabel!
	@IBOutlet private var lunchText: UILabel!
	@IBOutlet private var roomNumText: UILabel!
	@IBOutlet private var blockImage: UITextField!
	@IBOutlet private var block1Image: UITextField!
	@IBOutlet private var block2Image: UITextField!
	@IBOutlet private var block3Image: UITextField!
	@IBOutlet private var block4Image: UITextField!
	private var blockNumImageForNum:[Int:UITextField]!
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
		
        [block1Image, block2Image, block3Image, block4Image, blockImage].forEach({Cell.round($0)})
		blockNumImageForNum = [1:block1Image, 2:block2Image, 3:block3Image, 4:block4Image]
	}
	func configure(teacher:TeacherYours)
	{
		showRoomNumOfTeacher(teacher)
		showLunchOfTeacher(teacher)
		showBlockNumsOfTeacher(teacher)
		blockImage.text = teacher.blockLetter
		teacherName.text = teacher.name
		
        Cell.color(accordingTo: teacher.blockLetter, colorType: .normal, view: blockImage)
	}
	private func showRoomNumOfTeacher(_ teacher:TeacherYours)
	{
		if let roomNum = teacher.roomNum
		{
			roomNumText.isHidden = false
			roomNumText.text = String.local("roomNum") + roomNum
		}
		else
		{
			roomNumText.isHidden = true
		}
	}
	private func showLunchOfTeacher(_ teacher:TeacherYours)
	{
		if let lunch = teacher.lunch
		{
			lunchText.isHidden = false
			lunchText.text = String.local("\(lunch)Lunch")
			lunchText.sizeToFitRight()
		}
		else
		{
			lunchText.isHidden = true
			lunchText.text = ""
			lunchText.sizeToFitRight()
		}
	}
	private func showBlockNumsOfTeacher(_ teacher:TeacherYours)
	{
		for blockNum in Block.BLOCK_NUMBERS
		{
			if (teacher.blockNums.contains(blockNum))
			{
                Cell.color(accordingTo: teacher.blockLetter, colorType: .normal, view: blockNumImageForNum[blockNum]!)
			}
			else
			{
				//if the teacher doesn't teach this blockNum, fade it ou
				Cell.color(accordingTo: teacher.blockLetter, colorType: .light, view: blockNumImageForNum[blockNum]!)
			}
		}
	}
}
