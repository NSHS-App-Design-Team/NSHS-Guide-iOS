//
//  AppDelegate.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/1/18.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
	{
        //crossVersionUpdates()
		setNavBarColor()
		setTabBarColor()
		return true
	}
    private func crossVersionUpdates()
    {
        guard !Settings.wasCurrentVersion() else {
            return
        }
        
        //update for version 2.0. REMEMBER TO CHANGE EVERY VERSION!!!
        let regID = Settings.getRegId()
        let timeAdjust = Settings.getWidgetTimeAdjust()
        Settings.removeAll()
        if (regID != nil) {
            Settings.setRegId(regID!)
        }
        Settings.setWidgetTimeAdjust(timeAdjust)
        Settings.setCurrentVersion()
    }
	private func setNavBarColor()
	{
		let navigationBarAppearence = UINavigationBar.appearance()
		navigationBarAppearence.tintColor = UIColor.white
		navigationBarAppearence.barTintColor = AppColors.colorPrimaryDark.uicolor()
		navigationBarAppearence.isTranslucent = false
		navigationBarAppearence.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
	}
	private func setTabBarColor()
	{
		window?.tintColor = AppColors.colorPrimary.uicolor()
	}
	
	// for our lovely APN service
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
	{
		let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
		print("device token: \(deviceTokenString)")
		Internet.sendRegId(deviceTokenString)
	}
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
	{
		//oh well, try again next time
	}
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
	{
		handleNotification(userInfo: userInfo)
	}
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
	{
		handleNotification(userInfo: userInfo)
		completionHandler(.newData)
	}
	private func handleNotification(userInfo:[AnyHashable: Any])
	{
		print(userInfo)
		
		guard let info = userInfo["data"] as? [String:String] else {
            Internet.sendErrorMessage("Couldn't decipher notification info: \(userInfo)")
			return
		}
		Internet.performActionOnJSON(info, showNotification: true, app: UIApplication.shared)
	}
	func application(_ application: UIApplication, didReceive notification: UILocalNotification)
	{
	}
	func applicationWillResignActive(_ application: UIApplication)
	{
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	func applicationDidEnterBackground(_ application: UIApplication)
	{
		Settings.finishSavingImmediately()
	}
	func applicationWillEnterForeground(_ application: UIApplication)
	{
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	func applicationDidBecomeActive(_ application: UIApplication)
	{
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		registerAPN()
		
		let containerVC = window?.rootViewController as? TabBarVC
		let absentTeachersVC = containerVC?.selectedViewController as? AbsentTeachersVC
		absentTeachersVC?.load()
	}
	private func registerAPN()
	{
		if (!Settings.isRegisteredInDatabase())
		{
            if #available(iOS 10.0, *)
            {
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge], completionHandler:
                {
                    (granted, error) in
                    if (granted)
                    {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                })
            }
            else
            {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
        
		}
	}
	func applicationWillTerminate(_ application: UIApplication)
	{
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}
