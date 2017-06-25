//
//  TeacherManager.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/7/21.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

/**
 Masterclass for handling the block schedule and teacher absences in general.
 */
class TeacherManager
{
    static let FREE_BLOCK = String.local("freeBlock")
    static let CANCELLED_CLASS = String.local("cancelledClass")
    
	//suppress default constructor for noninstantiability
	private init(){}
    
    /**
     Returns the blocks for the given day, taking into consideration special schedules, no school days, and good ol' weekends
     - parameter day: The day for which we wish to know the blocks of
     - returns: An array of blocks, or nil if no school
     */
	static func blocks(for day:LocalDate) -> [Block]?
	{
		guard day.isWeekday() else {
			return nil
		}
        
        let scheduleType = Settings.getScheduleType(for: day)
        switch (scheduleType)
        {
        case .noSchool:
            return nil
        case .normal:
            return Block.BLOCKS_FOR_DAY[day.getDayOfWeek()]!
        case .special:
            return Settings.getSpecialScheduleForDay(day)
        }
	}
    /**
     Returns the blocks for the given day with lunch blocks relevant to the user.
     - parameter day: The day for which we wish to know the blocks of
     - returns: An array of blocks with lunch specially formatted, or nil if no school
     */
    static func getBlocksWithLunches(for day:LocalDate) -> [Block]?
    {
        if var blocks = blocks(for: day)
        {
            if (hasFreeOrCancelledLunch(blocks: blocks, day:day))
            {
                insertAllLunches(into: &blocks)
            }
            else
            {
                insertLunches(into: &blocks)
            }
            return blocks
        }
        return nil
    }
    /**
     Returns true if the user has free or cancelled class during lunch for the given day. Note that his class cannot be cancelled unless his teacher is absent, which cannot be true unless the day in question is today.
     - parameters:
        - blocks: Blocks on the given day
        - day: The day for which we wish to know the blocks of
     - returns: See method description
     */
	static func hasFreeOrCancelledLunch(blocks:[Block], day:LocalDate) -> Bool
	{
		guard let lunchBlock = blocks.filter({$0.isLunchBlock}).first else {
			return false
		}
        if (day.isToday())
        {
            return isFreeBlock(lunchBlock) || isCancelledClass(lunchBlock)
        }
		else
        {
            return isFreeBlock(lunchBlock)
        }
	}
    /**
     Appends the times for 1st, 2nd, and 3rd lunch into the given block schedule, using an inout array for efficiency (copies pointers instead of everything within the array).
     - parameter blocks: Blocks array to insert lunch blocks into
     */
    static func insertAllLunches(into blocks:inout [Block])
    {
        for i in 0..<blocks.count
        {
            let block = blocks[i]
            guard block.isLunchBlock else {
                continue
            }
            
            let lunch1 = Block.createLunch(1, classBlock: block)
            let lunch2 = Block.createLunch(2, classBlock: block)
            let lunch3 = Block.createLunch(3, classBlock: block)
            blocks.insert(lunch1, at: i+1)
            blocks.insert(lunch2, at: i+2)
            blocks.insert(lunch3, at: i+3)
            return
        }
    }
    /**
     Appends the correct lunch for the user into the given block schedule, while splitting up the original, "full" block, keeping only times when actual class (and not lunch) occurs. Uses an inout array for efficiency (copies pointers instead of everything within the array).
     - parameter blocks: Blocks array to insert lunch blocks into
     */
    static func insertLunches(into blocks:inout [Block])
	{
		for i in 0..<blocks.count
		{
			guard blocks[i].isLunchBlock else {
				continue
			}
			
			let block = blocks[i]
            let lunchNum = Settings.getLunchNum(for: block.letter)
			let lunch = Block.createLunch(lunchNum, classBlock: block)
			
			blocks.remove(at: i)
			switch (lunchNum)
			{
			case 1:
				blocks.insert(lunch, at: i)
				blocks.insert(Block(letter: block.letter, num: block.num, startTime: lunch.endTime, endTime: block.endTime, isLunchBlock: false), at: i + 1)
			case 2:
				blocks.insert(Block(letter: block.letter, num: block.num, startTime: block.startTime, endTime: lunch.startTime, isLunchBlock: false), at: i)
				blocks.insert(lunch, at: i + 1)
				blocks.insert(Block(letter: block.letter, num: block.num, startTime: lunch.endTime, endTime: block.endTime, isLunchBlock: false), at: i + 2)
			case 3:
				blocks.insert(Block(letter: block.letter, num: block.num, startTime: block.startTime, endTime: lunch.startTime, isLunchBlock: false), at: i)
				blocks.insert(lunch, at: i + 1)
			default:
				print("TeacherManager.insertLunches() received incorrect lunch: \(lunchNum)")
			}
			return
		}
	}
    /**
     Determines which of the absent teachers are your teachers and returns the separate arrays of absent teachers, both yours and the others. This method also has the side effect of SAVING all of YOUR absent teachers, so it can be used to just update that  if the list of absent teachers changes.
     - returns: A tuple containing a list of all of the other absent teachers and all of your absent teachers
     */
	static func absentTeachers() -> (others:[TeacherOtherAbsent], yours:[TeacherYourAbsent])?
	{
		//returns nil if no absent teachers exist or no school exists for today
		guard let allAbsentTeachers = Settings.getAbsentTeachersForToday() else {
			return nil
		}
        guard let blocks = blocks(for: LocalDate()) else {
			return nil
		}
		var otherAbsentTeachers = allAbsentTeachers
		var yourAbsentTeachers = [TeacherYourAbsent]()
		
		for block in blocks
		{
            guard let teacher = Settings.getTeacher(blockLetter: block.letter, blockNum: block.num) else {
				continue
			}
			guard let matchingAbsentTeacher = allAbsentTeachers.filter({$0.name == teacher.name}).first else {
				continue
			}
			guard matchingAbsentTeacher.absentForBlock[block.letter]! else {
				continue
			}
			
			yourAbsentTeachers.append(TeacherYourAbsent(name: teacher.name, info: matchingAbsentTeacher.info, block: block))
			if let index = otherAbsentTeachers.index(of: matchingAbsentTeacher) {
				otherAbsentTeachers.remove(at: index)
			}
		}
		
		Settings.setYourAbsentTeachers(yourAbsentTeachers)
		return (otherAbsentTeachers, yourAbsentTeachers)
	}
    /**
     Determines what text to show given a block and a list of your absent teachers. There are 4 possibilities:
     1. It's a lunch block, then show what lunch it is
     2. The class is cancelled
     3. It's a free block
     4. Normal class
     - parameters:
        - block: The block to find the text of
        - yourAbsentTeachersBlocks: The list of your absent teachers
     - returns: A tuple containing the main text to display and a roomNum to display if applicable and the info exists
     */
    static func teacherTextAndRoomNumForBlock(_ block:Block, yourAbsentTeachersBlocks:[String]?) -> (text:String, roomNum:String?)
	{
        let teacher = Settings.getTeacher(block: block)
		if (block.letter == "L") {
            return (text:String.local("\(block.num)Lunch"), roomNum:teacher?.roomNum)
		}
        if (isCancelledClass(block, yourAbsentTeachersBlocks: yourAbsentTeachersBlocks)) {
            return (text:CANCELLED_CLASS, roomNum:nil)
        }
        if (teacher == nil) {
            return (text:FREE_BLOCK, roomNum:nil)
        }
        return (text:teacher!.getNameOrSubject(), roomNum:teacher!.roomNum)
	}
    /**
     See above method. Assumes the block is part of today's schedule. This method is less efficient as your absent teachers must be read from memory and re-converted into [String] array every time it is called.
     - parameter block: The block to find the text of
     - returns: A tuple containing the main text to display and a roomNum to display if applicable and the info exists
     */
	static func teacherTextAndRoomNumForBlock(_ block:Block) -> (text:String, roomNum:String?)
	{
		return teacherTextAndRoomNumForBlock(block, yourAbsentTeachersBlocks: Settings.getYourAbsentTeachersBlocks())
	}
    /**
     Returns true if the user has no teacher for this particular block.
     - parameter block: Block in question
     - returns: See method description
     */
	static func isFreeBlock(_ block:Block) -> Bool
	{
		return !Settings.teacherExists(blockLetter: block.letter, blockNum: block.num)
	}
	//yourAbsentTeachersBlocks provided in parameters to save on CPU (only retrieve array once in a loop or a list)
    /**
     Returns true if the user's teacher is absent for the given block.
     - parameters:
        - block: Block in question
        - yourAbsentTeachersBlocks: The list of your absent teachers
     - returns: See method description
     */
	static func isCancelledClass(_ block:Block, yourAbsentTeachersBlocks:[String]?) -> Bool
	{
		guard yourAbsentTeachersBlocks != nil else {
			return false
		}
		return yourAbsentTeachersBlocks!.contains(block.getBlock())
	}
    /**
     See above method. Assumes the block is part of today's schedule. This method is less efficient as your absent teachers must be read from memory and re-converted into [String] array every time it is called.
     - parameter block: Block in question
     - returns: True if the user's teacher is absent for the given block
     */
	static func isCancelledClass(_ block:Block) -> Bool
	{
		guard let yourAbsentTeachersBlocks = Settings.getYourAbsentTeachersBlocks() else {
			return false
		}
		return isCancelledClass(block, yourAbsentTeachersBlocks: yourAbsentTeachersBlocks)
	}
}
