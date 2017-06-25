//
//  TeacherSingleBlock.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/6/18.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

struct TeacherYours
{
	let name:String
	let lunch:Int?
	let blockLetter:String
	let blockNums:[Int]
	let subject:String?
	let roomNum:String?
	
	init(name:String, lunch:Int?, blockLetter:String, blockNums:[Int], subject:String?, roomNum:String?)
	{
		self.name = name
		self.lunch = lunch
		self.blockNums = blockNums
		self.blockLetter = blockLetter
		self.subject = subject
		self.roomNum = roomNum
	}
	
	func save()
	{
		var builder = TeacherSingleBlock.Builder()
		builder.name = name
		builder.blockLetter = blockLetter
		builder.subject = subject
		builder.roomNum = roomNum
		blockNums.forEach({
			builder.blockNum = $0
			Settings.setTeacherSingleBlock(builder.build())
		})
		if let lunchNum = lunch
		{
			Settings.setLunchNum(lunchNum, blockLetter: blockLetter)
		}
	}
	func remove()
	{
        blockNums.forEach({Settings.removeTeacher(for: "\(blockLetter)\($0)")})
		if (lunch != nil)
		{
            Settings.removeLunchNum(for: blockLetter)
		}
	}
	//special builder made just for AddTeacherVC
	struct Builder
	{
		var name:String?
		var lunch:Int?
		var blockNums = [Int]()
		var blockLetter:String?
		var subject:String?
		var roomNum:String?
		
		func build() -> TeacherYours
		{
			return TeacherYours(name: name!, lunch: lunch, blockLetter: blockLetter!, blockNums: blockNums, subject: subject, roomNum: roomNum)
		}
	}
}
