//
//  TeacherWithBlock.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2016/6/10.
//  Copyright © 2016年 NSHS App Design Team. All rights reserved.
//

import Foundation

/**
 Similar to `TeacherSingleBlock`, with the distinction of actually obtaining a reference to the block the teacher teaches. This is so we can extract further info concerning the block, for example, the times it starts and ends.
 */
struct TeacherWithBlock
{
    let teacher:TeacherSingleBlock
    let block:Block
    
    init(teacher:TeacherSingleBlock, block:Block)
    {
        self.teacher = teacher
        self.block = block
    }
}
