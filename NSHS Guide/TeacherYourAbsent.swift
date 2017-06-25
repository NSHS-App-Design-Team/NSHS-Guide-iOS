//
//  TeacherYourAbsent.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/7/24.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

struct TeacherYourAbsent:Teacher, Comparable
{
	let name:String
	let info:String?
	let block:Block
	
	init(name:String, info:String?, block:Block)
	{
		self.name = name
		self.info = info
		self.block = block
	}
	func getType() -> TeacherType
	{
		return info == nil ? .yourTeacherNoInfo : .yourTeacher
	}
}
//comparable methods (have to be outside of protocol)
func < (lhs:TeacherYourAbsent, rhs:TeacherYourAbsent) -> Bool
{
	return lhs.block.letter < rhs.block.letter
}
func == (lhs:TeacherYourAbsent, rhs:TeacherYourAbsent) -> Bool
{
	return lhs.block.letter == rhs.block.letter
}
