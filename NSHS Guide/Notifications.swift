//
//  Notificaions.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/7/21.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 Creates local push notifications to alert the user
 */
class Notifications
{
	//suppress default constructor for noninstantiability
	private init(){}
	
    /**
     Creates a silent notification.
     - parameters:
        - title: The title
        - body: The body
        - app: An instance of the UIApplication to show the notification with
     */
	static func create(title:String, body:String, app:UIApplication)
	{
		let notification = UILocalNotification()
		
		if #available(iOS 8.2, *)
		{
		    notification.alertTitle = title
			notification.alertBody = body
		}
		else
		{
			notification.alertBody = "\(title)\n\(body)"
		}
		app.presentLocalNotificationNow(notification)
	}
}
