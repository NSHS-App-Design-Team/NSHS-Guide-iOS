//
//  Settings.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/23.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 Provides a clean and convenient way to write/read from saved preferences without having to deal with UserDefaults. Modify this class as necessary as new types of information needs to be saved.
 - important: No communication with UserDefaults should be done outside of this class.
 */
class Settings
{
    /**
     The keys to all stored preferences. Add more keys as necessary as new types of information needs to be saved. The comment after each key details exactly how the information is stored.
     * ["foo", "bar"] indicates the use of a [String] array
     * ["foo":"bar"] indicates the use of a [String:String] dictionary
     
     - important: All booleans in UserDefaults is "false" by default, so name the keys so it makes sense that they are false when initialized
     */
	private enum Keys:String
	{
		case AbsentTeachers = "absentTeachers" //["Chu, David|111011110|info", "Lin, Eric|101101101|info"...]
		case YourAbsentTeachers = "yourAbsentTeachers" //["A1", "B2"...]
		case AbsentTeachersUpdateDate = "absentTeachersUpdateDate" //"7|24"
		case DefaultLandingPage = "defaultLandingPage" //"tabAbsentTeachers"
		case Announcement = "announcement" //["endEpoch":"123456", "info":"something to announce"]
		case WidgetTimeAdjust = "widgetTimeAdjust" //10
		case SpecialSchedule = "specialSchedule" //ordered BlockSpecial toString()'s separated by \n
        case SpecialScheduleDates = "specialScheduleDates"  //["2016-06-01", "2016-06-15", ...]
		case DeveloperModeOn = "developerModeOn" //false
		case TeachersList = "teachersList" //["Chu, David", "Lin, Eric"...]
		case SyncOff = "syncOff"	//false
		case RegId = "regId"	//"yourRegId"
        case CurrentVersion = "currentVersion"  //"2.0"
        case Name = "name"
        case Email = "email"
	}
	
    /**
     Used throughout this class to communicate with our saved settings
     */
	private static let DEFAULTS = UserDefaults(suiteName: "group.com.nshsappdesignteam.nshs-guide")!
	
	//suppress default constructor for noninstantiability
	private init(){}
	
	/*
	ABSENT TEACHERS
	*/
    /**
     Returns an array of absent teachers if there are absent teachers from today. Returns null otherwise
     - returns: Optional array of absent teachers
    */
	static func getAbsentTeachersForToday() -> [TeacherOtherAbsent]?
	{
		guard !noAbsencesToday() else {
			return nil
		}
        
        if let absentTeacherAsStrings = DEFAULTS.stringArray(forKey: Keys.AbsentTeachers.rawValue) {
            return absentTeacherAsStrings.map({TeacherOtherAbsent.fromString($0)})
        }
        return nil
	}
    /**
     Returns true if there are absent teachers from today. This can be true iff (checked in order)
     1. The absence teachers update date has been set
     2. The absent teachers are from TODAY, not an earlier date. Note that this check is done by comparing only month and day, not year (That would be overkill). If absences exist but the date is wrong, the update date will be removed to make this check faster the next time around
     - returns: Whether there are absent teachers from today
     */
	private static func noAbsencesToday() -> Bool
	{
		guard let absentTeachersUpdateDate = DEFAULTS.string(forKey: Keys.AbsentTeachersUpdateDate.rawValue) else {
			return false
		}
		
		let absentTeachersUpdateDateSplit = absentTeachersUpdateDate.components(separatedBy: "|")
		let updateMonth = Int(absentTeachersUpdateDateSplit[0])!
		let updateDay = Int(absentTeachersUpdateDateSplit[1])!
        let today = LocalDate()
        
        let noAbsencesToday = today.get(.month) != updateMonth || today.get(.day) != updateDay
        //if the absences aren't from today, they're old absences and will never be used. Remove them so this method runs faster next time
        if (noAbsencesToday) {
            removeAbsentTeachers()
        }
        return noAbsencesToday
	}
    /**
     Remove all information about absent teachers
     */
	private static func removeAbsentTeachers()
    {
        remove(.AbsentTeachers)
        remove(.AbsentTeachersUpdateDate)
        remove(.YourAbsentTeachers)
    }
    /**
     Save the list of absent teachers received from the database. This assumes the absences are formatted as a dictionary with the keys
     * "date", Value = "month|day" of absences
     * "0".."length", Value = "Chu, David|010011100|info"
     - note: See `TeacherOtherAbsent`'s fromString method
     - parameter jsonDictionary: Dictionary from JSON outputted by the database
     */
	static func setAbsentTeachers(jsonDictionary:[String:String])
	{
		let absentTeachers = listFromJSON(jsonDictionary)
		DEFAULTS.setValue(jsonDictionary[Internet.Keys.absenceDate.rawValue]!, forKey: Keys.AbsentTeachersUpdateDate.rawValue)
		DEFAULTS.setValue(absentTeachers, forKey: Keys.AbsentTeachers.rawValue)
	}
	
	/*
	YOUR ABSENT TEACHERS
	*/
    /**
     Returns the blocks in which YOU have absent teachers as a string array
     - returns: Blocks of your absent teachers like so: ["A1", "B2", ...]
     */
	static func getYourAbsentTeachersBlocks() -> [String]?
	{
		guard !noAbsencesToday() else {
			return nil
		}
		
		return DEFAULTS.object(forKey: Keys.YourAbsentTeachers.rawValue) as? [String]
	}
    /**
     Takes an array of your absent teachers and saves the blocks in which they're absent to save on recalculation.
     - parameter yourAbsentTeachers: An array of your teachers who are absent today
     */
	static func setYourAbsentTeachers(_ yourAbsentTeachers:[TeacherYourAbsent])
	{
		DEFAULTS.setValue(yourAbsentTeachers.map({$0.block.getBlock()}), forKey: Keys.YourAbsentTeachers.rawValue)
	}
	
	/*
	ANNOUNCEMENT
	*/
    /**
     Returns the relevant announcement if it one should be shown. It will only be shown if
     1. An announcement has been set
     2. The announcement is formatted correctly, as a dictionary with the keys "info" and "endEpoch"
     3. The announcement has yet to expire
     - returns: A string containing the announcement that should be shown
     */
	static func getAnnouncement() -> String?
	{
		if let announcementDictionary = DEFAULTS.object(forKey: Keys.Announcement.rawValue) as? [String:String]
        {
            if (announcementDictionary.keys.contains(Internet.Keys.announcementInfo.rawValue) && announcementDictionary.keys.contains(Internet.Keys.announcementEnd.rawValue))
            {
                if (timeCorrectForShowingAnnouncement(announcementDictionary))
                {
                    return announcementDictionary[Internet.Keys.announcementInfo.rawValue]
                }
            }
		}
        return nil
	}
    /**
     Returns true if the endEpoch of the given announcement is larger than the current epoch time, which means the announcement should be shown. If the time is incorrect, the announcement will be removed to make processing faster the next time we check
     - parameter announcementDictionary: A dictionary containing the key "endEpoch" that has a value that can be converted into an integer
     - returns: True if the announcement should be shown
     */
    private static func timeCorrectForShowingAnnouncement(_ announcementDictionary:[String:String]) -> Bool
    {
        let endDateInEpoch = Int(announcementDictionary[Internet.Keys.announcementEnd.rawValue]!)!
        let todayInEpoch = Int(Date().timeIntervalSince1970)
        let timeCorrect = todayInEpoch <= endDateInEpoch
        //if the announcement isn't to be shown now, it will never be shown. Remove the announcement so it fails faster next time
        if (!timeCorrect) {
            remove(Keys.Announcement)
        }
        return timeCorrect
    }
    /**
     Saves the announcement received from the database. This assumes the announcement is formatted as a dictionary with the keys
     * "info", Value = String which contains the announcement to show
     * "endEpoch", Value = Int, epoch time when the announcement should no longer show
     */
	static func setAnnouncement(_ announcementDictionary:[String:String])
	{
		DEFAULTS.set(announcementDictionary, forKey: Keys.Announcement.rawValue)
	}
	
	/*
	SPECIAL SCHEDULE
	*/
    /**
     Returns the special schedule for the given day if one exists.
     - parameter date: The date for which we wish to retreive the special schedule
     - returns: Array of blocks for the given day's special schedule
     */
    static func getSpecialScheduleForDay(_ date:LocalDate) -> [Block]?
	{
		guard let specialSchedule = DEFAULTS.string(forKey: keyForDay(Keys.SpecialSchedule, day: date)) else {
			return nil
		}
        let parts = specialSchedule.components(separatedBy: "\n")
        return parts.map({getBlock(from: $0)})
	}
    /**
     Converts a string into a block, saving the name of the special block if necessary.
     - parameter string: A string containing information about a block. See `Block`'s fromString method
     - returns: Block
     */
    private static func getBlock(from string:String) -> Block
    {
        let block = Block.fromString(string)
        saveCustomBlockNameAsTeacher(block: block)
        return block
    }
    /**
     Save the block's custom name iff
     1. The block is special (not a normal block with different times)
     2. The block has a custom name
     3. The block's letter is "S"
     The block's custom name is then saved the same way teachers are saved, where the key is the block, presumably something like "S1". (Yes, this is a workaround)
     - note: Due to the way the custom block names are saved, if another special schedule block is saved with the same block letter and number, all previous info will be overwritten.
     - parameter block: The block whose custom name will be saved if it passes the above conditions
     */
    private static func saveCustomBlockNameAsTeacher(block:Block)
    {
        guard let blockSpecial = block as? BlockSpecial else {
            return
        }
        guard !blockSpecial.customName.isEmpty else {
            return
        }
        guard block.letter == "S" else {    //only save custom name for special blocks to avoid unwanted overriding
            return
        }
        
        var classAsTeacher = TeacherSingleBlock.Builder()
        classAsTeacher.blockLetter = block.letter
        classAsTeacher.blockNum = block.num
        classAsTeacher.name = blockSpecial.customName
        setTeacherSingleBlock(classAsTeacher.build())
    }
    /**
     Returns the special schedule stored on the day given.
     - parameter dayText: Text formatted according to `Internet`'s SPECIAL_SCHEDULE_DATE_PATTERN
     - returns: String containing special schedule info if it exists
     */
    static func getSpecialScheduleText(for dayText:String) -> String?
    {
        return DEFAULTS.string(forKey: "\(Keys.SpecialSchedule.rawValue)\(dayText)")
    }
    /**
     Returns what kind of schedule type is on the given date
     * Normal: returned if no special schedule exists
     * No school: returned if special schedule exists but is empty
     * Special: returned if special schedule exists and isn't empty
     - parameter date: The date for which we wish to know the schedule type
     - returns: Schedule type for given date
     */
    static func getScheduleType(for date:LocalDate) -> ScheduleType
    {
        let schedule = DEFAULTS.string(forKey: keyForDay(Keys.SpecialSchedule, day: date))
        
        if (schedule == nil) {
            return .normal
        }
        if (schedule!.isEmpty) {
            return .noSchool
        }
        else {
            return .special
        }
    }
    /**
     Adds and removes special schedules according to that the database says. Adding schedules includes adding a new key-value entry for the specific date, and then adding that date to a list of special schedule dates. Removing schedules involves a similar and opposite process.
     The dates should be formatted according to `Internet`'s SPECIAL_SCHEDULE_DATE_PATTERN, each date separated by "|"
     
     - parameter jsonDictionary: A dictionary with the following keys:
        * "datesToRemove", value = [String] array of dates to remove
        * "datesToAdd", value = [String] array of dates to add
        * "some date to add", value = special schedule for each date included in "datesToAdd"
     */
    static func addAndRemoveSpecialSchedules(jsonDictionary:[String:String])
    {
        print(jsonDictionary)
        let datesToRemoveString = jsonDictionary[Internet.Keys.specialScheduleRemove.rawValue]!
        let datesToAddString = jsonDictionary[Internet.Keys.specialScheduleAdd.rawValue]!
        let datesToRemove = datesToRemoveString.components(separatedBy: "|")
        let datesToAdd = datesToAddString.components(separatedBy: "|")
        
        if (!datesToRemoveString.isEmpty)
        {
            datesToRemove.forEach({DEFAULTS.removeObject(forKey: "\(Keys.SpecialSchedule.rawValue)\($0)")})
        }
        if (!datesToAddString.isEmpty)
        {
            datesToAdd.forEach({DEFAULTS.setValue(jsonDictionary[$0]!, forKey: "\(Keys.SpecialSchedule.rawValue)\($0)")})
        }
        
        var specialScheduleDates = getSpecialScheduleDates() ?? [String]()
        specialScheduleDates = specialScheduleDates.filter({!datesToRemove.contains($0)})
        if (!datesToAddString.isEmpty)
        {
            specialScheduleDates.append(contentsOf: datesToAdd)
        }
        setSpecialScheduleDates(specialScheduleDates)
    }
    /**
     Returns a string of dates for which there are special schedules (including no school days)
     - returns: See method description
     */
    static func getSpecialScheduleDates() -> [String]?
    {
        return DEFAULTS.stringArray(forKey: Keys.SpecialScheduleDates.rawValue)
    }
    /**
     Sets the special schedule dates array
     - parameter dates: Dates for which there are special schedules, formatted according to `Internet`'s SPECIAL_SCHEDULE_DATE_PATTERN
     */
    static func setSpecialScheduleDates(_ dates:[String])
    {
        DEFAULTS.setValue(dates, forKey: Keys.SpecialScheduleDates.rawValue)
    }
	
	/*
	SAVED TEACHERS & LUNCHES
	*/
    /**
     Saves information about a teacher with the key being the block letter and number combined, like "A1"
     - parameter teacher: The teacher to save
     */
	static func setTeacherSingleBlock(_ teacher:TeacherSingleBlock)
	{
		DEFAULTS.setValue(teacher.description, forKey: "\(teacher.blockLetter)\(teacher.blockNum)")
	}
    /**
     Returns a teacher for the given block letter and num, nil if none exists
     - parameters:
        - blockLetter: String, like "A"
        - blockNum: Int, like 1
     - returns: A teacher who teaches during this block
     */
	static func getTeacher(blockLetter:String, blockNum:Int) -> TeacherSingleBlock?
	{
		guard let string = DEFAULTS.string(forKey: "\(blockLetter)\(blockNum)") else {
			return nil
		}
		return TeacherSingleBlock.fromString(string, blockLetter: blockLetter, blockNum: blockNum)
	}
    /**
     Returns a teacher for the given block
     - parameter block: Block when the teacher should teach
     - returns: A teacher who teaches during this block
     */
    static func getTeacher(block:Block) -> TeacherSingleBlock?
    {
        return getTeacher(blockLetter: block.letter, blockNum: block.num)
    }
    /**
     Returns true if a teacher teaches during the given block
     - parameters:
        - blockLetter: String, like "A"
        - blockNum: Int, like 1
     - returns: See method description
     */
	static func teacherExists(blockLetter:String, blockNum:Int) -> Bool
	{
		return DEFAULTS.string(forKey: "\(blockLetter)\(blockNum)") != nil
	}
    /**
     Removes the teacher for the given block String.
     - parameter block: String, like "A1"
     */
	static func removeTeacher(for block:String)
	{
		DEFAULTS.removeObject(forKey: block)
	}
    /**
     Sets the lunch number (1st, 2nd, or 3rd) for the given block
     - parameters:
        - num: Int, like 1
        - blockLetter: String, like "A"
     */
	static func setLunchNum(_ num:Int, blockLetter:String)
	{
		DEFAULTS.set(num, forKey: "\(blockLetter)Lunch")
	}
    /**
     Returns the lunch num for the given block, or 1 by default
     - parameter blockLetter: String, like "A"
     - returns: An integer representing the lunch the student will take during this block
     */
	static func getLunchNum(for blockLetter:String) -> Int
	{
		let savedLunch = DEFAULTS.integer(forKey: "\(blockLetter)Lunch")
		//default to 1st lunch
		return savedLunch == 0 ? 1 : savedLunch
	}
    /**
     Removes the lunch num for the given block
     - parameter blockLetter: String, like "A"
     */
	static func removeLunchNum(for blockLetter:String)
	{
		DEFAULTS.removeObject(forKey: "\(blockLetter)Lunch")
	}
    
    /*
     OTHER SETTINGS
     */
    /**
     Returns true if the user has his deviceToken registered in the online database
     - returns: See above
     */
    static func isRegisteredInDatabase() -> Bool
    {
        return getRegId() != nil
    }
    /**
     Returns the deviceToken the way it's stored in the database. Mainly used for debugging
     - returns: String containing the deviceToken
     */
    static func getRegId() -> String?
    {
        return DEFAULTS.string(forKey: Keys.RegId.rawValue)
    }
    /**
     Saves the deviceToken
     - parameter regId: Device token as string
     */
    static func setRegId(_ regId:String)
    {
        DEFAULTS.setValue(regId, forKey: Keys.RegId.rawValue)
    }
    /**
     Returns a `Tabs` object representing the landing page that should open when the app is launched. Defaults to absent teachers
     - returns: The default landing page that should open
     */
    static func getLandingPage() -> Tabs
    {
        let tabKey = DEFAULTS.integer(forKey: Keys.DefaultLandingPage.rawValue)
        return tabKey == 0 ? Tabs.absentTeachers : Tabs(rawValue: tabKey)!
    }
    /**
     Saves the default landing page. This is done (behind the scenes) using rawValues that correspond to the enum `Tabs`. These rawValues should NOT change between versions
     - parameter name: The default landing page
     */
    static func setLandingPage(_ name:Tabs)
    {
        DEFAULTS.set(name.rawValue, forKey: Keys.DefaultLandingPage.rawValue)
    }
    /**
     Returns an Int representing how early before a block starts we should start showing it in the widget. For example, if 5 is returned and B block starts next, the widget will show B block 5 minutes before it starts
     - returns: See above. Defaults to 10
     */
    static func getWidgetTimeAdjust() -> Int
    {
        //integerForKey returns 0 by default, so use objectForKey instead & check for nil
        let adjust = DEFAULTS.object(forKey: Keys.WidgetTimeAdjust.rawValue) as? Int
        return adjust ?? 10
    }
    /**
     Set the widget adjust time. See the method `getWidgetTimeAdjust()`
     - parameter adjust: Widget adjust time. Should >= 0
     */
    static func setWidgetTimeAdjust(_ adjust:Int)
    {
        DEFAULTS.set(adjust, forKey: Keys.WidgetTimeAdjust.rawValue)
    }
    /**
     Returns true if developer mode is on.
     - returns: See above
     */
    static func getDeveloperModeOn() -> Bool
    {
        return DEFAULTS.bool(forKey: Keys.DeveloperModeOn.rawValue)
    }
    /**
     Sets developer mode.
     - parameter on: True if developer mode should be on
     */
    static func setDeveloperModeOn(_ on:Bool)
    {
        DEFAULTS.set(on, forKey: Keys.DeveloperModeOn.rawValue)
    }
    /**
     Returns a string array of the list of valid teachers. Formatted as "LastName, FirstName"
     - returns: See above.
     */
    static func getTeachersList() -> [String]?
    {
        return DEFAULTS.object(forKey: Keys.TeachersList.rawValue) as? [String]
    }
    /**
     Sets the list of valid teachers according to a JSON provided by the database. 
     - parameter jsonDictionary: Dictionary with incrementing String keys (from "0" to "length") and values that are the teachers names
     */
    static func setTeachersList(_ jsonDictionary:[String:String])
    {
        DEFAULTS.set(listFromJSON(jsonDictionary), forKey: Keys.TeachersList.rawValue)
    }
    /**
     Returns true if sync is on. This means pages should automatically query the database for new information when they are clicked on, instead of having the user manually refresh.
     - returns: See above.
     */
    static func isSyncOn() -> Bool
    {
        //methods request syncOn for readability, key stored as syncOff because we want default to be on, but bools default to false
        return !DEFAULTS.bool(forKey: Keys.SyncOff.rawValue)
    }
    /**
     Sets sync on or off.
     - parameter on: True if sync should be turned on
     */
    static func setSyncOn(_ on:Bool)
    {
        DEFAULTS.set(!on, forKey: Keys.SyncOff.rawValue)
    }
    /**
     Returns true if the app was not just recently updated to a higher version. This will also return true on the 1st installation of the app. This method exists in case some stored preferences need to be updated between versions but the update should only run ONCE
     - returns: True if the stored version is the current running version
     */
    static func wasCurrentVersion() -> Bool
    {
        if let storedVersion = DEFAULTS.value(forKey: Keys.CurrentVersion.rawValue) as? String
        {
            return storedVersion == actualCurrentVersion()
        }
        return false
    }
    /**
     Saves the current version as the stored version number. This ensures that `wasCurrentVersion()` will return true next time it's called (and the app's version number has not changed)
     */
    static func setCurrentVersion()
    {
        DEFAULTS.setValue(actualCurrentVersion(), forKey: Keys.CurrentVersion.rawValue)
    }
    /**
     Returns a string containing the current version of the app, such as "2.0".
     - returns: See above
     */
    private static func actualCurrentVersion() -> String
    {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    /**
     Returns the name of the user.
     - returns: See above
     */
    static func getName() -> String?
    {
        return DEFAULTS.string(forKey: Keys.Name.rawValue)
    }
    /**
     Sets the name of the user.
     - parameter name: The name of the user
     */
    static func setName(_ name:String)
    {
        DEFAULTS.setValue(name, forKey: Keys.Name.rawValue)
    }
    /**
     Returns the email of the user.
     - returns: See above
     */
    static func getEmail() -> String?
    {
        return DEFAULTS.string(forKey: Keys.Email.rawValue)
    }
    /**
     Sets the email of the user.
     - parameter email: The email of the user
     */
    static func setEmail(_ email:String)
    {
        DEFAULTS.setValue(email, forKey: Keys.Email.rawValue)
    }
	
	/*
	MISCELLANEOUS
	*/
    /**
     Force all recently changed settings to be applied immediately. Otherwise, the settings would be saved ASYNCHRONOUSLY, whihc may result in issues if we attempt to read values immediately after we "save" it
     - important: Do not call this method unless necessary
     */
	static func finishSavingImmediately()
	{
		DEFAULTS.synchronize()
	}
    /**
     Returns the key of a specific day's preference (currently only used for special schedule. Each special schedule is stored separately, each under a key like "SpecialSchedule2016-12-31")
     - parameters:
        - key: The enum
        - day: The date
     - returns: Key as a string
     */
    private static func keyForDay(_ key:Keys, day:LocalDate) -> String
	{
		return "\(key.rawValue)\(day.format(Internet.SPECIAL_SCHEDULE_DATE_PATTERN))"
	}
    /**
     Converts a JSON dictionary with incrementing string keys to a String array in order.
     - parameter jsonDictionary: Dictionary with keys "0", "1", .. "length"
     - return: String array containing values of incrementing keys in order. Note that this array will be empty if the JSON has no key "0"
     */
	private static func listFromJSON(_ jsonDictionary:[String:String]) -> [String]
	{
		var list = [String]()
		var i = 0
		while let nextString = jsonDictionary[String(i)]
		{
			list.append(nextString)
			i = i + 1
		}
		return list
	}
    /*
     Delete the object stored in the key given.
     - parameter key: Key to delete value of
     */
    private static func remove(_ key:Keys)
    {
        DEFAULTS.removeObject(forKey: key.rawValue)
    }
    /**
     Delete ALL settings and apply it immediately. Be careful!
     */
    static func removeAll()
    {
        print("All settings removed")
        let keysAndValues = DEFAULTS.dictionaryRepresentation()
        keysAndValues.keys.forEach({DEFAULTS.removeObject(forKey: $0)})
        DEFAULTS.synchronize()
    }
    /*
     Print all the settings. Used for debugging.
     */
    static func printAll()
    {
        print(DEFAULTS.dictionaryRepresentation())
    }
}
