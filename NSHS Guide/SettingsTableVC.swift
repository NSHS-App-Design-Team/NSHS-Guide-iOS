//
//  SettingsTableVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/23.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class SettingsTableVC:UITableViewController
{
	@IBOutlet private var defaultLandingPageCell:UITableViewCell!
	@IBOutlet private var widgetTimeAdjustCell:UITableViewCell!
	@IBOutlet private var syncSwitch:UISwitch!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		updateDefaultLandingPageCell()
		updateSyncSwitch()
		updateWidgetTimeAdjustCell()
	}
	private func updateWidgetTimeAdjustCell()
	{
		widgetTimeAdjustCell.detailTextLabel?.text = String(Settings.getWidgetTimeAdjust())
	}
	private func updateSyncSwitch()
	{
		syncSwitch.isOn = Settings.isSyncOn()
	}
	@IBAction func updateSyncSettings(_ sender:UISwitch)
	{
		Settings.setSyncOn(sender.isOn)
	}
	private func updateDefaultLandingPageCell()
	{
		defaultLandingPageCell.detailTextLabel?.text = Settings.getLandingPage().toString()
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		//should create protocol in future if multiple segues exist (protocol classes must have "updateMethod")
		if (segue.identifier == "timeAdjustment")
		{
			let timeAdjustVC = segue.destination as! TimeAdjustVC
			timeAdjustVC.updateMethod = updateWidgetTimeAdjustCell
		}
		else if (segue.identifier == "defaultLandingPage")
		{
			let defaultLandingPageVC = segue.destination as! DefaultLandingPageVC
			defaultLandingPageVC.updateMethod = updateDefaultLandingPageCell
		}
	}
}
