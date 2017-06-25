//
//  Internet.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/20.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit
import SystemConfiguration

/**
 Handles all communications with the database, sending and receiving information. 
 - important: No over-the-web connections should be made outside of this class
 */
class Internet
{
    /**
     Enum containing all the URLs to be used for internet communication
     */
    private enum Urls:String
    {
        case regId = "http://nshsguide.newton.k12.ma.us/ajax/set-reg-id-ios.php"
        case feedback = "http://nshsguide.newton.k12.ma.us/feedback.php"
        case absentTeachers = "http://nshsguide.newton.k12.ma.us/ajax/absent-teachers.php"
        case announcement = "http://nshsguide.newton.k12.ma.us/ajax/get-announcement.php"
        case specialSchedule = "http://nshsguide.newton.k12.ma.us/ajax/special-schedule-list.php"
        case teachersList = "http://nshsguide.newton.k12.ma.us/ajax/get-faculty.php"
        case teacherRequest = "http://nshsguide.newton.k12.ma.us/ajax/set-teacher-request-ios.php"
    }
    /**
     Enum containing the value corresponding to the key "title" within JSONs outputted by the database. For example, a JSON dictionary containing info about absences will have the following entry "title":"Absent Teachers" to indicate its purpose.
     */
    private enum Titles:String
    {
        case absentTeachers = "Absent Teachers"
        case announcement = "Announcement"
        case specialSchedule = "Special Schedule"
        case teachersList = "Teachers List"
        case teacherRequest = "Request Teacher"
    }
    /**
     Enum containing keys for additional information POST'ed to the database or received from the database
     */
    enum Keys:String
    {
        case regId = "regID"
        case name = "name"
        case feedbackEmail = "email"
        case feedback = "feedback"
        case specialScheduleDates = "dates"
        case specialScheduleRemove = "datesToRemove"
        case specialScheduleAdd = "datesToAdd"
        case teacherRequestFirstName = "firstName"
        case teacherRequestLastName = "lastName"
        case teacherRequestApproved = "approved"
        case absenceDate = "date"
        case announcementInfo = "info"
        case announcementEnd = "endEpoch"
    }
    
    static let SPECIAL_SCHEDULE_DATE_PATTERN = "yyyy-MM-dd"
	
	//suppress default constructor for noninstantiability
	private init(){}
    
    /**
     Given a JSON dictionary outputted by the database, determines what to do with the information. This assumes the JSON has a key "title", which contains info about what kind of info is stored; the method fails gracefully otherwise, sending an error message to the database.
     - parameters:
        - jsonDictionary: [String:String] dictionary outputted by the server
        - showNotification: True if a notification should be shown where applicable (for announcements, for example). This should be set to false if communication to the server is done WHILE the app is open, because then the user doesn't need to be notified
        - app: An instance of the UIApplication to show the notification with. Should be nil only if showNotification is false
     */
	static func performActionOnJSON(_ jsonDictionary:[String:String], showNotification:Bool, app:UIApplication?)
	{
        guard let titleString = jsonDictionary["title"] else {
            sendErrorMessage("JSON has no key: 'title'. \(jsonDictionary)")
            return
        }
        guard let title = Titles(rawValue: titleString) else {
            sendErrorMessage("Invalid title in JSON. \(jsonDictionary)")
            return
        }
        
		print("performing action on JSON with title: \(titleString)")
		switch(title)
		{
		case .absentTeachers:
            Settings.setAbsentTeachers(jsonDictionary: jsonDictionary)
			Settings.finishSavingImmediately()
			let yourAbsentTeachers = TeacherManager.absentTeachers()?.yours
			if (showNotification)
			{
                notifyAbsentListUpdate(yourAbsentTeachers: yourAbsentTeachers, app: app!)
			}
		case .announcement:
			Settings.setAnnouncement(jsonDictionary)
			if (showNotification)
			{
				Settings.finishSavingImmediately()
                notifyAnnouncement(app: app!)
			}
		case .specialSchedule:
            Settings.addAndRemoveSpecialSchedules(jsonDictionary: jsonDictionary)
		case .teachersList:
			Settings.setTeachersList(jsonDictionary)
        case .teacherRequest:
            notifyTeacherRequest(jsonDictionary: jsonDictionary, app:app!)
		}
	}
    /**
     Sends a personalized notification updating the user on which teachers he has absent
     - parameters:
        - yourAbsentTeachers: A list of teachers YOU have absent
        - app: An instance of the UIApplication to show the notification with
     */
	private static func notifyAbsentListUpdate(yourAbsentTeachers:[TeacherYourAbsent]?, app:UIApplication)
	{
		let title = String.local("notificationAbsenceListUpdate")
        let info = getAbsentListInfo(yourAbsentTeachers: yourAbsentTeachers)
		
        Notifications.create(title: title, body: info, app: app)
		print("Absence list update, info: \(info)")
	}
    /**
     Shows the appropriate text to the user based on whether or not he has absent teachers, how many, etc
     - parameter yourAbsentTeachers: A list of teachers YOU have absent
     - returns: The string to show the user concerning how many teachers he has absent
     */
	private static func getAbsentListInfo(yourAbsentTeachers:[TeacherYourAbsent]?) -> String
	{
		guard yourAbsentTeachers != nil && !yourAbsentTeachers!.isEmpty else {
			return String.local("notificationBlocksCancelledZero")
		}
		
		var info = yourAbsentTeachers!.map({$0.block.letter}).joined(separator: ", ")
		info += String.local("notificationBlocksCancelledMany")
		return info
	}
    /**
     Shows the announcement as a notification
     - parameter app: An instance of the UIApplication to show the notification with
     */
	private static func notifyAnnouncement(app:UIApplication)
	{
		let title = String.local("notificationAnnouncement")
		guard let info = Settings.getAnnouncement() else {
			return
		}
		
        Notifications.create(title: title, body: info, app: app)
		print("Announcement, info: \(info)")
	}
    /**
     Shows the user a notification about whether his teacher request was denied or not
     - jsonDictionary: [String:String] dictionary outputted by the server. Should contain the keys "approved" and "name"
     - app: An instance of the UIApplication to show the notification with. Should be nil only if showNotification is false
     */
    private static func notifyTeacherRequest(jsonDictionary:[String:String], app:UIApplication)
    {
        let approved = jsonDictionary[Keys.teacherRequestApproved.rawValue] == "true"
        let teacherName = jsonDictionary[Keys.name.rawValue]!
        let title:String
        if (approved)
        {
            title = String.local("notificationTeacherRequestApproved")
        }
        else
        {
            title = String.local("notificationTeacherRequestDenied")
        }
        let body = String.local("notificationTeacherRequestName") + teacherName
        Notifications.create(title: title, body: body, app: app)
    }
	
	/*
	QUERY FUNCTIONS (RETURNS WHETHER QUERY WAS SUCCESSFUL)
	*/
    /**
     Attempt to retreive absence info
     - parameter completion: Function to run once we have attempted to communicate with the server
     */
	static func queryAbsentTeachers(completion:(() -> ())?)
	{
        post(url: .absentTeachers, keyValues: nil, completionFunction: completion)
	}
    /**
     Attempt to retreive announcement
     - parameter completion: Function to run once we have attempted to communicate with the server
     */
	static func queryAnnouncement(completion:(() -> ())?)
	{
        post(url: .announcement, keyValues: nil, completionFunction: completion)
	}
    /**
     Attempt to retreive faculty list
     - parameter completion: Function to run once we have attempted to communicate with the server
     */
	static func queryTeachersList(completion:(() -> ())?)
	{
        post(url: .teachersList, keyValues: nil, completionFunction: completion)
	}
    /**
     Attempt to retreive special schedule updates. Sends the special schedules we have stored on file so the server can determine the difference between our version and what's on the server.
     - parameter completion: Function to run once we have attempted to communicate with the server
     */
    static func querySpecialSchedule(completion:(() -> ())?)
    {
        let dates = Settings.getSpecialScheduleDates() ?? [String]()
        var keyValues = dates.map({(key:$0, value:Settings.getSpecialScheduleText(for: $0)!)})
        keyValues.append((key: Keys.specialScheduleDates.rawValue, value: dates.joined(separator: "|")))
        post(url: .specialSchedule, keyValues: keyValues, completionFunction: completion)
    }
    /**
     Sends feedback to the server
     - parameters:
        - name: The name of the user
        - email: The email of the user. Should be empty if unprovided
        - feedback: The info containing the feedback
     */
    static func sendFeedback(name:String, email:String, feedback:String)
    {
        post(url: .feedback, keyValues: [(Keys.name.rawValue, name), (Keys.feedbackEmail.rawValue, email), (Keys.feedback.rawValue, feedback)], completionFunction: nil)
    }
    /**
     Sends an error message to our server using the built-in feedback mechanism. Used for real-world debugging
     - parameter message: The error message
     */
    static func sendErrorMessage(_ message:String)
    {
        sendFeedback(name: "iOS error message", email: "", feedback: message)
    }
    /**
     Sends our deviceToken to the server so we can receive notifications in the future
     - parameter regID: Our device token
     */
    static func sendRegId(_ regID:String)
    {
        post(url: .regId, keyValues: [(Keys.regId.rawValue, regID)], completionFunction: {Settings.setRegId(regID)})
    }
    /**
     Sends the requested teacher to the server
     - parameters:
        - firstName: The first name of the requested teacher
        - lastName: The last name of the requested teacher
     */
    static func sendTeacherRequest(firstName:String, lastName:String)
    {
        let keyValues = [(key:Keys.teacherRequestFirstName.rawValue, value:firstName), (key:Keys.teacherRequestLastName.rawValue, value:lastName), (key:Keys.regId.rawValue, value:Settings.getRegId() ?? "")]
        
        post(url: .teacherRequest, keyValues: keyValues, completionFunction: nil)
    }
	/**
     Sends a POST request to the given URL with the given keys, running the completion function when it is done. Always use this function to communicate with the server.
     - parameters:
        - url: URL to send the POST request to
        - keyValues: The key values to send along with the POST request. These will be read by the server
        - completionFunction: The function that will be run when the POST request is done
     */
	private static func post(url:Urls, keyValues:[(key:String, value:String)]?, completionFunction:(() -> ())?)
	{
        let keyValuesString = keyValues == nil ? "" : keyValueToStringForPOST(keyValues!)
        
		var request = URLRequest(url: URL(string: url.rawValue)!)
		request.httpMethod = "POST"
		request.httpBody = keyValuesString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler:
        {
            data, response, error in
            
            //empty data = event unsuccessful
            guard data != nil else {
                runAsyncFunction(completionFunction)
                return
            }
            guard data!.count != 0 else {
                runAsyncFunction(completionFunction)
                return
            }
            do
            {
                if let info = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:String]
                {
                    self.performActionOnJSON(info, showNotification: false, app: nil)
                }
                runAsyncFunction(completionFunction)
            }
            catch
            {
                print("unwrapping from JSON error")
            }
        })
		task.resume()
	}
    /**
     Converts the given key values to a form recognizable by the server, in the following format: "key1=value1&key2=value2..."
     - parameter keyValues: The key values to convert
     - returns: A string in the server-readable key value format
     */
	private static func keyValueToStringForPOST(_ keyValues:[(key:String, value:String)]) -> String
	{
		let combinedKeyValues = keyValues.map({"\($0.key)=\($0.value)"})
		return combinedKeyValues.joined(separator: "&")
	}
    /**
     Runs the given function asynchronously. Used because Internet communications should not be done on the UI-thread.
     - parameter function: Function to run
     */
    private static func runAsyncFunction(_ function:(() -> ())?)
    {
        if (function == nil) {
            return
        }
        DispatchQueue.main.async(execute: {
            function?()
        })
    }
}
