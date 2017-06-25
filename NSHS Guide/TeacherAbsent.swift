//
//  TeacherAbsent.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/6/18.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

struct TeacherOtherAbsent:Teacher, Comparable
{
	private static let PRESENT:Character = "0"
	private static let ABSENT:Character = "1"
	let name:String
	let info:String?
	let absentForBlock:[String:Bool]
	
	private init(name:String, info:String?, absentForBlock:[String:Bool])
	{
		self.name = name
		if (info == nil || info!.isEmpty)
		{
			self.info = nil
		}
		else
		{
			self.info = info
		}
		self.absentForBlock = absentForBlock
	}
	//static factory method
	static func fromString(_ string:String) -> TeacherOtherAbsent
	{
		//assumes absent teacher is stored as such: "Chu, David|010011100|info"
		let teacherWithInfo = string.components(separatedBy: "|")
		let name = teacherWithInfo[0]
		let absentBlocks = teacherWithInfo[1]
		let info = teacherWithInfo[2]
		
        return self.init(name: name, info: info, absentForBlock:absentBlocksDictionary(from: absentBlocks))
	}
	private static func absentBlocksDictionary(from absentBlocks:String) -> [String:Bool]
	{
		var absentForBlock = [String:Bool]()
		var i = 0
		for char in absentBlocks.characters
		{
			let blockLetter = Block.BLOCK_LETTERS[i]
			absentForBlock[blockLetter] = (char == TeacherOtherAbsent.ABSENT)
			i = i + 1
		}
		return absentForBlock
	}
	func getType() -> TeacherType
	{
		return info == nil ? .otherTeacherNoInfo : .otherTeacher
	}
}
//comparable methods (have to be outside of protocol)
func < (lhs:TeacherOtherAbsent, rhs:TeacherOtherAbsent) -> Bool
{
	return lhs.name < rhs.name
}
func == (lhs:TeacherOtherAbsent, rhs:TeacherOtherAbsent) -> Bool
{
	return lhs.name == rhs.name
}
