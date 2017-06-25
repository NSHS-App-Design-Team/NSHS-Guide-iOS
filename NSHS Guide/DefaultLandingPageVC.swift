//
//  DefaultLandingPageVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/23.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class DefaultLandingPageVC:UITableViewController
{
	@IBOutlet private var absentTeachersCell: UITableViewCell!
	@IBOutlet private var blocksCell: UITableViewCell!
	//cells & tabs must completely correspond
	private var cells:[UITableViewCell]!
	private let tabs:[Tabs] = [.absentTeachers, .blocks]
	var updateMethod:(() -> ())!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		cells = [absentTeachersCell, blocksCell]
		setCellChecked(cells[tabs.index(of: Settings.getLandingPage())!])
	}
	private func setCellChecked(_ cell:UITableViewCell)
	{
		cells.forEach({$0.accessoryType = .none})
		cell.accessoryType = .checkmark
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		Settings.setLandingPage(tabs[indexPath.row])
		Settings.finishSavingImmediately()
		setCellChecked(cells[indexPath.row])
		
		updateMethod()
		navigationController?.popViewController(animated: true)
	}
}
