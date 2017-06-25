//
//  BlockCell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2016/6/10.
//  Copyright © 2016年 NSHS App Design Team. All rights reserved.
//

import UIKit

class BlockCell:BlockNoRoomNumCell
{
    @IBOutlet private var roomNumText:UILabel!
    
    override func configure(teacher: TeacherWithBlock)
    {
        super.configure(teacher: teacher)
        roomNumText.text = String.local("roomNum") + teacher.teacher.roomNum!
    }
}
