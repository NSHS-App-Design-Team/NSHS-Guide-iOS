//
//  TeacherSingleBlock.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/11/14.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

/**
 Stores information about a teacher and the single block he teaches WITHOUT storing any references to the block. This format is used to store teachers and to retreive them for `YourTeachersVC`. No references to the block are included because including those would require looking through every single block in the weekly schedule, which is time-consuming and often unnecessary.
 */
struct TeacherSingleBlock:Equatable, CustomStringConvertible
{
	let blockLetter:String
	let blockNum:Int
	let name:String
	let subject:String?
	let roomNum:String?
	var description:String
	{
		//convert nil to ""
		let subjectText = (subject == nil ? "" : subject!)
		let roomNumText = (roomNum == nil ? "" : roomNum!)
		return name + "|" + subjectText + "|" + roomNumText
	}
	
    /**
     Private initializer that should only be called by `fromString()` or `Builder`.`build()`
     - parameters:
        - name: The name of the teacher
        - blockLetter: The letter of the block this teacher teaches
        - blockNum: The number of the block this teacher teaches
        - subject: The subject taught. If provided, this will show instead of the teacher's name
        - roomNum: The room where the class is taught
     */
	private init(name:String, blockLetter:String, blockNum:Int, subject:String?, roomNum:String?)
	{
		self.name = name
		self.blockLetter = blockLetter
		self.blockNum = blockNum
		self.subject = subject
		self.roomNum = roomNum
	}
    /**
     Returns the subject if it isn't nil, the teachers name otherwise
     - returns: See above
     */
    func getNameOrSubject() -> String
    {
        return subject ?? name
    }
    /**
     Converts from a saved string back into a `TeacherSingleBlock` object. This works in tandem with var `description`. Note that blockLetter and blockNum aren't stored as part of the string, since those are the keys to the teacher when saved.
     - parameters:
        - string: String to convert to this object from. Doesn't have to contain info about the subject or roomNum
        - blockLetter: The letter of the block this teacher teaches
        - blockNum: The number of the block this teacher teaches
     - returns: Instance of `TeacherSingleBlock`
     */
	static func fromString(_ string:String, blockLetter:String, blockNum:Int) -> TeacherSingleBlock
	{
		let parts = string.components(separatedBy: "|")
		var builder = Builder()
		builder.blockLetter = blockLetter
		builder.blockNum = blockNum
		builder.name = parts[0]
		if (parts.count > 1)
		{
			//convert "" to nil
			builder.subject = (parts[1].isEmpty ? nil : parts[1])
			builder.roomNum = (parts[2].isEmpty ? nil : parts[2])
		}
		return builder.build()
	}
	
    /**
     Implementation of the builder pattern, used for quick mutations of fields, designed to handle instant changes due to user interactions.
     */
	struct Builder
	{
		var blockLetter:String?
		var blockNum:Int?
		var name:String?
		var subject:String?
		var roomNum:String?
		
        /**
         Creates an instance of `TeacherSingleBlock`, assuming required fields were filled.
         - important: This method will crash if the required fields (name, blockLetter, and blockNum) are not filled. Make sure to check before calling this method
         - returns: Instance of `TeacherSingleBlock`
         */
		func build() -> TeacherSingleBlock
		{
			return TeacherSingleBlock(name: name!, blockLetter: blockLetter!, blockNum: blockNum!, subject: subject, roomNum: roomNum)
		}
	}
}
/**
 Equivalent to .equals() in Java
 */
func == (lhs:TeacherSingleBlock, rhs:TeacherSingleBlock) -> Bool
{
	return lhs.blockLetter == rhs.blockLetter && lhs.blockNum == rhs.blockNum && lhs.name == rhs.name && lhs.subject == rhs.subject && lhs.roomNum == rhs.roomNum
}
