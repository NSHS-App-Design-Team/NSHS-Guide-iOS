//
//  BlockSpecial.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2016/6/4.
//  Copyright © 2016年 NSHS App Design Team. All rights reserved.
//

import Foundation

/**
 A block object created solely to accomadate special schedules. Includes the capability of specifying a custom block name and custom lunch times.
 */
class BlockSpecial:Block
{
    //customName can be empty string because when no custom name exists, it's stored as such: "||". Splitting by "|" produces empty string.
    let customName:String
    let firstLunchEnd:Time?
    let secondLunchStart:Time?
    let secondLunchEnd:Time?
    let thirdLunchStart:Time?
    
    /**
     Creates a special block.
     - parameters:
        - letter: The block letter, like "A"
        - num: The block num, like 1
        - startTime: When the block starts
        - endTime: When the block ends. This does not include passing time
        - isLunchBlock: True iff this block is the CLASS that contains lunch for the given day. Like D1 on Mondays, for example
        - customName: The custom name to show for this block. CANNOT be null, but can be an empty string. This is to make saving and converting back from a saved string easier
        - firstLunchEnd: The custom time when first lunch ends, if this is a lunch block that does not follow normal lunch schedules. If this field is provided, all the other lunch fields are assumed to exist as well
        - secondLunchStart: See `firstLunchEnd`
        - secondLunchEnd: See `firstLunchEnd`
        - thirdLunchStart: See `firstLunchEnd`
     - note: The parameters "firstLunchStart" and "thirdLunchEnd" are noticeably missing. This is because they are assumed to coincide with the start and end of this block, respectively.
     */
    init(letter:String, num:Int, startTime:Time, endTime:Time, isLunchBlock:Bool, customName:String, firstLunchEnd:Time?, secondLunchStart:Time?, secondLunchEnd:Time?, thirdLunchStart:Time?)
    {
        self.customName = customName
        self.firstLunchEnd = firstLunchEnd
        self.secondLunchStart = secondLunchStart
        self.secondLunchEnd = secondLunchEnd
        self.thirdLunchStart = thirdLunchStart
        super.init(letter:letter, num:num, startTime:startTime, endTime:endTime, isLunchBlock:isLunchBlock)
    }
    /**
     Same as `Block`'s `toString()` with a few vital differences.
     * An empty slot is kept for the custom name, regardless of whether one exists.
     * If a custom first lunch end time exists, it's assumed that all the other custom lunch times exist as well, and these are converted to string too.
     - returns: String representation
     */
    override func toString() -> String
    {
        var output = "\(super.toString())|\(customName)"
        if (firstLunchEnd != nil)
        {
            output += "|\(firstLunchEnd!)|\(secondLunchStart!)|\(secondLunchEnd!)|\(thirdLunchStart!)"
        }
        return output
    }
}
/**
 Equivalent to .equals() in Java
 */
func == (lhs:BlockSpecial, rhs:BlockSpecial) -> Bool
{
    return lhs.letter == rhs.letter && lhs.num == rhs.num && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime && lhs.isLunchBlock == rhs.isLunchBlock && lhs.customName == rhs.customName && lhs.firstLunchEnd == rhs.firstLunchEnd && lhs.secondLunchStart == rhs.secondLunchStart && lhs.secondLunchEnd == rhs.secondLunchEnd && lhs.thirdLunchStart == rhs.thirdLunchStart
}
