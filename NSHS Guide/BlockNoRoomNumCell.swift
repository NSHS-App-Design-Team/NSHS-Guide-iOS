//
//  BlockNoRoomNumCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2016/6/10.
//  Copyright © 2016年 NSHS App Design Team. All rights reserved.
//

import UIKit

class BlockNoRoomNumCell:UITableViewCell
{
    @IBOutlet private var teacherText:UILabel!
    @IBOutlet private var timeText:UILabel!
    @IBOutlet private var blockImage:UITextField!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        Cell.round(blockImage)
    }
    func configure(teacher:TeacherWithBlock)
    {
        Cell.color(accordingTo: teacher.block.letter, colorType: .normal, view: blockImage)
        blockImage.attributedText = teacher.block.getBlockWithNumSubscript(for: blockImage)
        timeText.text = teacher.block.getTimeString()
        
        let nameOrSubject = teacher.teacher.getNameOrSubject()
        teacherText.text = nameOrSubject
        if (nameOrSubject == TeacherManager.FREE_BLOCK || nameOrSubject == TeacherManager.CANCELLED_CLASS)
        {
            backgroundColor = AppColors.blueGreyLight.uicolor()
        }
        else
        {
            backgroundColor = UIColor.white
        }
    }
}
