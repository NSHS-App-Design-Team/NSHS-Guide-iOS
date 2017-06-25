//
//  AbsentTeacherNoInfoCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/24.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class AbsentTeacherNoInfoCell:UITableViewCell
{
	@IBOutlet private var teacherName: UILabel!
	private var blockImages = [UITextField]()
	
	func configure(teacher:TeacherOtherAbsent, blocks:[Block])
	{
		teacherName.text = teacher.name
		
		if (blockImages.isEmpty)
		{
			setUpBlockImages(blocks: blocks)
		}
		colorBlockImages(teacher: teacher, blocks: blocks)
	}
	private func setUpBlockImages(blocks:[Block])
	{
		for i in 0..<blocks.count
		{
			let blockLetter = blocks[i].letter
			let blockImage = UITextField()
			blockImage.frame = CGRect(x: CGFloat(72 + 24 * i), y: 38, width: 18, height: 18)
			blockImage.text = blockLetter
			blockImage.textColor = UIColor.white
			blockImage.textAlignment = .center
			blockImage.font = UIFont.systemFont(ofSize: 10)
			blockImage.isUserInteractionEnabled = false
			Cell.round(blockImage)
			contentView.addSubview(blockImage)
			blockImages.append(blockImage)
		}
	}
	private func colorBlockImages(teacher:TeacherOtherAbsent, blocks:[Block])
	{
		for i in 0..<blocks.count
		{
			let blockLetter = blocks[i].letter
			
			if (teacher.absentForBlock[blockLetter]!)
			{
				Cell.color(accordingTo: blockLetter, colorType: .normal, view: blockImages[i])
			}
			else
			{
				Cell.color(accordingTo: blockLetter, colorType: .light, view: blockImages[i])
			}
		}
	}
}
