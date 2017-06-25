//
//  AbsentTeachersVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/2/2.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class AbsentTeachersVC:UIViewController, UITableViewDataSource, UITableViewDelegate
{
	@IBOutlet private var teacherTable: UITableViewEmptyState!
	private let refreshControl = UIRefreshControl()

	private var announcement:String?
	private var yourAbsentTeachers = [TeacherYourAbsent]()
	private var otherAbsentTeachers = [TeacherOtherAbsent]()
	private var blocks:[Block]!
	
	private let SECTION_ANNOUNCEMENTS = 0
	private let SECTION_YOUR_TEACHERS = 1
	private let SECTION_OTHER_TEACHERS = 2
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
        blocks = TeacherManager.blocks(for: LocalDate())
		addSwipeToRefresh()
	}
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		
		load()
		sync()
	}
	private func addSwipeToRefresh()
	{
		refreshControl.tintColor = AppColors.accent.uicolor()
        refreshControl.addTarget(self, action: #selector(startRefresh), for: .valueChanged)
		teacherTable.addSubview(refreshControl)
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		guard segue.identifier == AddTeacherVC.SEGUE_ID else {
			print("AbsentTeachersVC prepareForSegue called with weird id: \(segue.identifier)")
			return
		}
		
		let addTeacherVC = segue.destination as! AddTeacherVC
		addTeacherVC.setUpdatableData(resetMethod: loadTeachers, teacherToEdit: nil)
	}
	func startRefresh()
	{
		//unowned keyword in case Internet completes after we switch to a different VC and self no longer exists
		let absencesFuncToRun =
		{
			[unowned self] () -> () in
			if (self.refreshControl.isRefreshing)
			{
				self.refreshControl.endRefreshing()
			}
			self.loadTeachers()
			self.toggleEmptyState()
		}
		let announcementFuncToRun =
		{
			[unowned self] () -> () in
			if (self.refreshControl.isRefreshing)
			{
				self.refreshControl.endRefreshing()
			}
			self.announcement = Settings.getAnnouncement()
			self.toggleEmptyState()
			self.teacherTable.reloadData()
			self.view.setNeedsDisplay()
		}
		
		Internet.queryAbsentTeachers(completion: absencesFuncToRun)
		Internet.queryAnnouncement(completion: announcementFuncToRun)
	}
	func load()
	{
		announcement = Settings.getAnnouncement()
		loadTeachers()
		toggleEmptyState()
	}
	private func loadTeachers()
	{
		guard let absentTeachers = TeacherManager.absentTeachers() else {
			yourAbsentTeachers.removeAll(keepingCapacity: false)
			otherAbsentTeachers.removeAll(keepingCapacity: false)
			teacherTable.reloadData()
			view.setNeedsDisplay()
			return
		}
		
		//must use local arrays because UITableView might attempt to redraw cells & find the global array mutating & crash
		var tempOtherAbsentTeachers = absentTeachers.others
		var tempYourAbsentTeachers = absentTeachers.yours
		tempYourAbsentTeachers.sort(by: <)
		tempOtherAbsentTeachers.sort(by: <)
		yourAbsentTeachers = tempYourAbsentTeachers
		otherAbsentTeachers = tempOtherAbsentTeachers
		
		teacherTable.reloadData()
		view.setNeedsDisplay()
	}
	private func toggleEmptyState()
	{
		shouldShowEmptyState() ? teacherTable.setEmptyStateType(.NoAbsentTeacher) : teacherTable.hideEmptyState()
	}
	private func shouldShowEmptyState() -> Bool
	{
		return otherAbsentTeachers.isEmpty && yourAbsentTeachers.isEmpty && announcement == nil
	}
	private func sync()
	{
		if (Settings.isSyncOn())
		{
			startRefresh()
		}
	}
	
	/*
	TABLE VIEW STUFF
	*/
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 3
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch(section)
		{
		case SECTION_ANNOUNCEMENTS:
			return announcement != nil ? 1 : 0
		case SECTION_YOUR_TEACHERS:
			return yourAbsentTeachers.count
		case SECTION_OTHER_TEACHERS:
			return otherAbsentTeachers.count
		default:
			print("weird section in AbsentTeachers")
			return 0
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell:UITableViewCell
		switch(indexPath.section)
		{
		case SECTION_ANNOUNCEMENTS:
			cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell", for: indexPath) 
			cell.textLabel?.text = announcement
		case SECTION_YOUR_TEACHERS:
			let absentTeacher = yourAbsentTeachers[indexPath.row]
			let yourAbsentTeacherCell:YourAbsentTeacherNoInfoCell
			if (absentTeacher.info != nil)
			{
				yourAbsentTeacherCell = tableView.dequeueReusableCell(withIdentifier: "yourAbsentTeacherCell", for: indexPath) as! YourAbsentTeacherCell
			}
			else
			{
				yourAbsentTeacherCell = tableView.dequeueReusableCell(withIdentifier: "yourAbsentTeacherNoInfoCell", for: indexPath) as! YourAbsentTeacherNoInfoCell
			}
			yourAbsentTeacherCell.configure(teacher: absentTeacher)
			cell = yourAbsentTeacherCell as UITableViewCell
		case SECTION_OTHER_TEACHERS:
			let absentTeacher = otherAbsentTeachers[indexPath.row]
			let otherAbsentTeacherCell:AbsentTeacherNoInfoCell
			if (absentTeacher.info != nil)
			{
				otherAbsentTeacherCell = tableView.dequeueReusableCell(withIdentifier: "absentTeacherCell", for: indexPath) as! AbsentTeacherCell
			}
			else
			{
				otherAbsentTeacherCell = tableView.dequeueReusableCell(withIdentifier: "absentTeacherNoInfoCell", for: indexPath) as! AbsentTeacherNoInfoCell
			}
			otherAbsentTeacherCell.configure(teacher: absentTeacher, blocks: blocks!)
			cell = otherAbsentTeacherCell as UITableViewCell
		default:
			print("weird cell in AbsentTeachers")
			return UITableViewCell()
		}
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		tableView.deselectRow(at: indexPath, animated: false)
		
		switch(indexPath.section)
		{
		case SECTION_ANNOUNCEMENTS:
			Popup.withTitle(String.local("alertInfoTitle"), message: announcement!, presentingClass: self)
		case SECTION_YOUR_TEACHERS:
			//show the user info if there is any to show
			guard let info = yourAbsentTeachers[indexPath.row].info else {
				return
			}
			Popup.withTitle(String.local("alertInfoTitle"), message: info, presentingClass: self)
		case SECTION_OTHER_TEACHERS:
			//show the user info if there is any to show
			guard let info = otherAbsentTeachers[indexPath.row].info else {
				return
			}
			Popup.withTitle(String.local("alertInfoTitle"), message: info, presentingClass: self)
		default:
			print("weird selected row in AbsentTeachers")
			return
		}
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		switch(indexPath.section)
		{
		case SECTION_ANNOUNCEMENTS:
			return LayoutConstants.listOneLineNoImageHeight.rawValue
		case SECTION_YOUR_TEACHERS:
			let info = yourAbsentTeachers[indexPath.row].info
			return info != nil ? LayoutConstants.listTwoLineHeight.rawValue : LayoutConstants.listOneLineHeight.rawValue
		case SECTION_OTHER_TEACHERS:
			let info = otherAbsentTeachers[indexPath.row].info
			return info != nil ? LayoutConstants.listThreeLineHeight.rawValue : LayoutConstants.listTwoLineHeight.rawValue
		default:
			print("weird section in AbsentTeachers")
			return 0
		}
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		//don't show headers if the empty state is showing
		guard !shouldShowEmptyState() else {
			return nil
		}
		
		switch(section)
		{
		case SECTION_ANNOUNCEMENTS:
			return String.local("sectionHeaderAnnouncements")
		case SECTION_YOUR_TEACHERS:
			return String.local("sectionHeaderYourTeachers")
		case SECTION_OTHER_TEACHERS:
			return String.local("sectionHeaderOtherTeachers")
		default:
			return "weird header in AbsentTeachers"
		}
	}
}
