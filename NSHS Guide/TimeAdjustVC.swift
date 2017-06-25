//
//  TimeAdjustVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/6/7.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class TimeAdjustVC: UITableViewController
{
	@IBOutlet private var fiveMinCell:UITableViewCell!
	@IBOutlet private var tenMinCell:UITableViewCell!
	@IBOutlet private var fifteenMinCell:UITableViewCell!
	private var cellForMinutes:[Int:UITableViewCell]!
	var updateMethod:(() -> ())!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		cellForMinutes = [5:fiveMinCell, 10:tenMinCell, 15:fifteenMinCell]
		setCellChecked(cellForMinutes[Settings.getWidgetTimeAdjust()]!)
	}
	private func setCellChecked(_ cell:UITableViewCell)
	{
		cellForMinutes.values.forEach({$0.accessoryType = .none})
		cell.accessoryType = .checkmark
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let selectedCell = tableView.cellForRow(at: indexPath)!
		let minutes = Int(selectedCell.textLabel!.text!)!
		Settings.setWidgetTimeAdjust(minutes)
		Settings.finishSavingImmediately()
		setCellChecked(selectedCell)
		
		updateMethod()
		navigationController?.popViewController(animated: true)
	}
}
