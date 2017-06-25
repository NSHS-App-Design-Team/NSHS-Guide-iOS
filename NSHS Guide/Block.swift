//
//  Block.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/3/15.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 Fundamental building block of the app. Blocks are periods of time within which classes occur; they are independent of teachers or their absence. T
 */
class Block:Equatable, CustomStringConvertible
{
	static let BLOCK_LETTERS = ["A", "B", "C", "D", "E", "F", "G", "HR", "J"]
	static let BLOCK_NUMBERS = [1, 2, 3, 4]
	static let BLOCKS_ON_MONDAY = [Block(letter: "A", num: 1, startTime: Time(hour: 7, minute: 40), endTime: Time(hour: 8, minute: 35), isLunchBlock: false), Block(letter: "B", num: 1, startTime: Time(hour: 8, minute: 40), endTime: Time(hour: 9, minute: 35), isLunchBlock: false), Block(letter: "HR", num: 1, startTime: Time(hour: 9, minute: 40), endTime: Time(hour: 9, minute: 45), isLunchBlock: false), Block(letter: "C", num: 1, startTime: Time(hour: 9, minute: 50), endTime: Time(hour: 10, minute: 45), isLunchBlock: false), Block(letter: "D", num: 1, startTime: Time(hour: 10, minute: 50), endTime: Time(hour: 12, minute: 35), isLunchBlock: true), Block(letter: "E", num: 1, startTime: Time(hour: 12, minute: 40), endTime: Time(hour: 13, minute: 35), isLunchBlock: false), Block(letter: "F", num: 1, startTime: Time(hour: 13, minute: 40), endTime: Time(hour: 14, minute: 35), isLunchBlock: false), Block(letter: "J", num: 1, startTime: Time(hour: 14, minute: 40), endTime: Time(hour: 15, minute: 20), isLunchBlock: false)]
	static let BLOCKS_ON_TUESDAY = [Block(letter: "G", num: 1, startTime: Time(hour: 7, minute: 40), endTime: Time(hour: 8, minute: 35), isLunchBlock: false), Block(letter: "F", num: 2, startTime: Time(hour: 8, minute: 40), endTime: Time(hour: 9, minute: 35), isLunchBlock: false), Block(letter: "HR", num: 2, startTime: Time(hour: 9, minute: 40), endTime: Time(hour: 10, minute: 5), isLunchBlock: false), Block(letter: "C", num: 2, startTime: Time(hour: 10, minute: 10), endTime: Time(hour: 11, minute: 5), isLunchBlock: false), Block(letter: "E", num: 2, startTime: Time(hour: 11, minute: 10), endTime: Time(hour: 12, minute: 55), isLunchBlock: true), Block(letter: "D", num: 2, startTime: Time(hour: 13, minute: 0), endTime: Time(hour: 13, minute: 55), isLunchBlock: false)]
	static let BLOCKS_ON_WEDNESDAY = [Block(letter: "A", num: 2, startTime: Time(hour: 7, minute: 40), endTime: Time(hour: 8, minute: 55), isLunchBlock: false), Block(letter: "B", num: 2, startTime: Time(hour: 9, minute: 0), endTime: Time(hour: 9, minute: 55), isLunchBlock: false), Block(letter: "G", num: 2, startTime: Time(hour: 10, minute: 0), endTime: Time(hour: 10, minute: 55), isLunchBlock: false), Block(letter: "F", num: 3, startTime: Time(hour: 11, minute: 0), endTime: Time(hour: 12, minute: 45), isLunchBlock: true), Block(letter: "D", num: 3, startTime: Time(hour: 12, minute: 50), endTime: Time(hour: 13, minute: 45), isLunchBlock: false), Block(letter: "E", num: 3, startTime: Time(hour: 13, minute: 50), endTime: Time(hour: 14, minute: 45), isLunchBlock: false), Block(letter: "J", num: 2, startTime: Time(hour: 14, minute: 50), endTime: Time(hour: 15, minute: 20), isLunchBlock: false)]
	static let BLOCKS_ON_THURSDAY = [Block(letter: "A", num: 3, startTime: Time(hour: 7, minute: 40), endTime: Time(hour: 8, minute: 35), isLunchBlock: false), Block(letter: "B", num: 3, startTime: Time(hour: 8, minute: 40), endTime: Time(hour: 9, minute: 35), isLunchBlock: false), Block(letter: "HR", num: 3, startTime: Time(hour: 9, minute: 40), endTime: Time(hour: 9, minute: 45), isLunchBlock: false), Block(letter: "F", num: 4, startTime: Time(hour: 9, minute: 50), endTime: Time(hour: 10, minute: 45), isLunchBlock: false), Block(letter: "G", num: 3, startTime: Time(hour: 10, minute: 50), endTime: Time(hour: 12, minute: 35), isLunchBlock: true), Block(letter: "E", num: 4, startTime: Time(hour: 12, minute: 40), endTime: Time(hour: 13, minute: 35), isLunchBlock: false), Block(letter: "C", num: 3, startTime: Time(hour: 13, minute: 40), endTime: Time(hour: 14, minute: 35), isLunchBlock: false), Block(letter: "J", num: 3, startTime: Time(hour: 14, minute: 40), endTime: Time(hour: 15, minute: 20), isLunchBlock: false)]
	static let BLOCKS_ON_FRIDAY = [Block(letter: "A", num: 4, startTime: Time(hour: 7, minute: 40), endTime: Time(hour: 8, minute: 35), isLunchBlock: false), Block(letter: "B", num: 4, startTime: Time(hour: 8, minute: 40), endTime: Time(hour: 9, minute: 55), isLunchBlock: false), Block(letter: "HR", num: 4, startTime: Time(hour: 10, minute: 0), endTime: Time(hour: 10, minute: 5), isLunchBlock: false), Block(letter: "G", num: 4, startTime: Time(hour: 10, minute: 10), endTime: Time(hour: 11, minute: 5), isLunchBlock: false), Block(letter: "C", num: 4, startTime: Time(hour: 11, minute: 10), endTime: Time(hour: 12, minute: 55), isLunchBlock: true), Block(letter: "D", num: 4, startTime: Time(hour: 13, minute: 0), endTime: Time(hour: 13, minute: 55), isLunchBlock: false)]
    /**
     All the hard-coded block information is outputted by the BlocksParser, which exists in the Android repo. Should the blocks schedule ever change, using the BlocksParser to auto-generate the new hard-coded block info for Android, iOS, and PHP, then upload a new app.
     */
	static let BLOCKS_FOR_DAY:[DayOfWeek:[Block]] = [.monday:Block.BLOCKS_ON_MONDAY, .tuesday:Block.BLOCKS_ON_TUESDAY, .wednesday:Block.BLOCKS_ON_WEDNESDAY, .thursday:Block.BLOCKS_ON_THURSDAY, .friday:Block.BLOCKS_ON_FRIDAY]
	static let LUNCH_BLOCK_FOR_DAY:[DayOfWeek:String] = [.monday:"D1", .tuesday:"E2", .wednesday:"F3", .thursday:"G3", .friday:"C4"]
	static let END_MINUTE_FOR_DAY:[DayOfWeek:Int] = [.monday:20, .tuesday:55, .wednesday:20, .thursday:20, .friday:55]
	static let TIME_LUNCH = 30
	static let TIME_SECOND_LUNCH_CLASS_BEFORE_LUNCH = 35
	static let NORMAL_BLOCK_LENGTH = 55
	let letter:String
	let num:Int
	let startTime, endTime:Time
	let isLunchBlock:Bool
	
    /**
     Creates a block object.
     - parameters:
        - letter: The block letter, like "A"
        - num: The block num, like 1
        - startTime: When the block starts
        - endTime: When the block ends. This does not include passing time
        - isLunchBlock: True iff this block is the CLASS that contains lunch for the given day. Like D1 on Mondays, for example
     */
	init(letter:String, num:Int, startTime:Time, endTime:Time, isLunchBlock:Bool)
	{
		self.letter = letter
		self.num = num
		self.startTime = startTime
		self.endTime = endTime
		self.isLunchBlock = isLunchBlock
	}
    /**
     Returns the block letter with the block number if it should. It shouldn't if this block is lunch (not lunch block, but lunch. Like 1st lunch).
     - returns: blockLetter + num, like "A1"
     */
	func getBlock() -> String
	{
		return shouldHideNum() ? letter : letter + String(num)
	}
    /**
     Returns an attributed string with a large block letter and a block number half the size of the block letter, as the subscript. This is what's displayed in block images.
     - parameter textField: The textField the attributed string is for. This is to calculate the new size of the subscripted number
     - returns: The attributed string
     */
	func getBlockWithNumSubscript(for textField:UITextField) -> NSMutableAttributedString
	{
		guard !shouldHideNum() else {
			return NSMutableAttributedString(string: letter)
		}
		
		let text = NSMutableAttributedString(string: getBlock())
		text.addAttribute(NSFontAttributeName, value: textField.font!.withSize(textField.font!.pointSize / 2), range: NSRange(location: text.length - 1, length: 1))
		return text
	}
    /**
     Determines if the number should be hidden for this block in the methods `getBlock()` and `getBlockWithNumSubscript`. The number is only hidden if this block is lunch (not lunch block, but lunch. Like 1st lunch).
     - returns: True if the number should be hidden
     */
	private func shouldHideNum() -> Bool
	{
		return letter == "L" || num == 0
	}
    /**
     Returns a string containing info about when the block starts and ends, formatted according to `Time`'s standard formatting.
     - returns: String detailing when block starts and ends
     */
	func getTimeString() -> String
	{
		return "\(startTime.description) ~ \(endTime.description)"
	}
    /**
     Returns how long this block lasts, in minutes.
     - returns: See above
     */
	func getDuration() -> Int
	{
        return Time.length(startTime: startTime, endTime: endTime)
	}
    /**
     Using a lunch block, as in the class during which the lunch occurs, a "lunch" is created, one that lasts (usually) `TIME_LUNCH` minutes, and can have the 3 possible times:
     1. 1st lunch precedes the class
     2. 2nd lunch is sandwiched by the class, starting this many minutes after the class starts: `TIME_SECOND_LUNCH_CLASS_BEFORE_LUNCH`
     3. 3rd lunch is preceded by the class
     This method takes into account special schedule blocks, which is, on one hand, not-clean code (since `BlockSpecial` is a descendent, and parents shouldn't have to worry about descendents). This is done only because static methods cannot be overriden.
     - parameters:
        - lunch: Either 1, 2, or 3
        - classBlock: The class during which the lunch occurs. AKA lunch block, but not named that way to avoid confusion
     - returns: The lunch created as a block
     */
	static func createLunch(_ lunch:Int, classBlock:Block) -> Block
	{
		let lunchStart:Time
		let lunchEnd:Time
        
        if (classBlock is BlockSpecial && (classBlock as! BlockSpecial).firstLunchEnd != nil)
        {
            let block = classBlock as! BlockSpecial
            switch(lunch)
            {
            case 1:
                lunchStart = block.startTime
                lunchEnd = block.firstLunchEnd!
            case 2:
                lunchStart = block.secondLunchStart!
                lunchEnd = block.secondLunchEnd!
            case 3:
                lunchStart = block.thirdLunchStart!
                lunchEnd = block.endTime
            default:
                lunchStart = Time(hour: 0, minute: 0)
                lunchEnd = Time(hour: 0, minute: 0)
                print("Block.createLunch() called with incorrect lunch: \(lunch)")
            }
        }
		else
        {
            switch(lunch)
            {
            case 1:
                lunchStart = classBlock.startTime
                lunchEnd = Time.add(startTime: lunchStart, minutesToAdd: TIME_LUNCH)
            case 2:
                lunchStart = Time.add(startTime: classBlock.startTime, minutesToAdd: TIME_SECOND_LUNCH_CLASS_BEFORE_LUNCH)
                lunchEnd = Time.add(startTime: lunchStart, minutesToAdd: TIME_LUNCH)
            case 3:
                lunchStart = Time.add(startTime: classBlock.endTime, minutesToAdd: -TIME_LUNCH)
                lunchEnd = classBlock.endTime
            default:
                lunchStart = Time(hour: 0, minute: 0)
                lunchEnd = Time(hour: 0, minute: 0)
                print("Block.createLunch() called with incorrect lunch: \(lunch)")
            }
        }
		
		return Block(letter: "L", num: lunch, startTime: lunchStart, endTime: lunchEnd, isLunchBlock: false)
	}
    /**
     Swift's equivalent to Java's toString()
     */
    var description: String
    {
        return toString()
    }
    /**
     Turns this block into a form recognized by its sister method, `fromString()`, or the server. This form of turning blocks to string is consistent across all platforms the app runs on.
     - returns: String containing all crucial info about this block
     */
    func toString() -> String
    {
        return "\(letter)|\(num)|\(startTime)|\(endTime)|\(isLunchBlock)"
    }
    /**
     Converts a string into a block object, taking into consideration special schedule blocks (`BlockSpecial`). Knowledge of descendent classes is not clean code, but as this is a static function that cannot be overriden, this is necessary.
     - note: This method will crash if the string is formatted incorrectly
     - parameter string: The string to convert from
     - returns: The block converted from the given string
     */
    static func fromString(_ string:String) -> Block
    {
        let parts = string.components(separatedBy: "|")
        let letter = parts[0]
        let num = Int(parts[1])!
        let startTime = Time.fromString(parts[2])
        let endTime = Time.fromString(parts[3])
        let isLunchBlock = parts[4] == "true"
        if (parts.count == 5) {
            return Block(letter: letter, num: num, startTime: startTime, endTime: endTime, isLunchBlock: isLunchBlock)
        }
        
        //must be a special block
        let customName = parts[5]
        let firstLunchEnd:Time?
        let secondLunchStart:Time?
        let secondLunchEnd:Time?
        let thirdLunchStart:Time?
        if (parts.count == 10)
        {
            firstLunchEnd = Time.fromString(parts[6])
            secondLunchStart = Time.fromString(parts[7])
            secondLunchEnd = Time.fromString(parts[8])
            thirdLunchStart = Time.fromString(parts[9])
        }
        else
        {
            firstLunchEnd = nil
            secondLunchStart = nil
            secondLunchEnd = nil
            thirdLunchStart = nil
        }
        return BlockSpecial(letter: letter, num: num, startTime: startTime, endTime: endTime, isLunchBlock: isLunchBlock, customName: customName, firstLunchEnd: firstLunchEnd, secondLunchStart: secondLunchStart, secondLunchEnd: secondLunchEnd, thirdLunchStart: thirdLunchStart)
    }
}
/**
 Equivalent to .equals() in Java. Note that a `BlockSpecial` can be incorrectly deemed equivalent to a `Block` due to how inheritance works.
 */
func == (lhs:Block, rhs:Block) -> Bool
{
	return lhs.letter == rhs.letter && lhs.num == rhs.num && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime && lhs.isLunchBlock == rhs.isLunchBlock
}
