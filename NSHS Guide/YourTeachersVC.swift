//
//  YourTeachersVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/2/2.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class YourTeachersVC:UIViewController, UITableViewDelegate, UITableViewDataSource
{
	@IBOutlet var teacherTable: UITableViewEmptyState!
	
	var savedTeachers = [TeacherYours]()
	var selectedTeacher:TeacherYours?
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		
		loadSavedTeachers()
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		guard segue.identifier == AddTeacherVC.SEGUE_ID else {
			print("YourTeachersVC prepareForSegue called with weird id: \(segue.identifier)")
			return
		}
		
		let addTeacherVC = segue.destination as! AddTeacherVC
		addTeacherVC.setUpdatableData(resetMethod: loadSavedTeachers, teacherToEdit: selectedTeacher)
		selectedTeacher = nil
	}
	
	/*
	TABLE VIEW STUFF
	*/
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return savedTeachers.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell:YourTeacherNoSubjectCell
		let teacher = savedTeachers[indexPath.row]
		if (teacher.subject == nil)
		{
			cell = tableView.dequeueReusableCell(withIdentifier: "yourTeacherNoSubjectCell", for: indexPath) as! YourTeacherNoSubjectCell
		}
		else
		{
			cell = tableView.dequeueReusableCell(withIdentifier: "yourTeacherCell", for: indexPath) as! YourTeacherCell
		}
		cell.configure(teacher: teacher)
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		selectedTeacher = savedTeachers[indexPath.row]
		performSegue(withIdentifier: AddTeacherVC.SEGUE_ID, sender: self)
		//get rid of the ugly gray selection bar
		tableView.deselectRow(at: indexPath, animated: true)
	}
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
	{
		return true
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
	{
		guard editingStyle == .delete else {
			return
		}
		
		// handle delete (by removing the data from your array and updating the tableview)
		let teacher = savedTeachers[indexPath.row]
		teacher.remove()
		
		Settings.finishSavingImmediately()
		TeacherManager.absentTeachers()
		savedTeachers.remove(at: indexPath.row)
		toggleEmptyState()
		tableView.deleteRows(at: [indexPath], with: .fade)
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		let teacher = savedTeachers[indexPath.row]
		return teacher.subject == nil ? LayoutConstants.listTwoLineHeight.rawValue : LayoutConstants.listThreeLineHeight.rawValue
	}
	
	/*
	PRIVATE FUNCTIONS
	*/
	private func loadSavedTeachers()
	{
		var tempSavedTeachers = [TeacherYours]()
		var teacherForBlockNum = [Int:TeacherSingleBlock]()
		var groupedBlockNums = [Int]()
		var builder = TeacherYours.Builder()
		
		for blockLetter in Block.BLOCK_LETTERS
		{
			teacherForBlockNum = getTeachersForBlock(blockLetter)
			
			for teacher in teacherForBlockNum.values
			{
				guard !groupedBlockNums.contains(teacher.blockNum) else {
					continue
				}
				
				let blockNums = teacherForBlockNum.values
					.filter({!groupedBlockNums.contains($0.blockNum)})
					.filter({teacher.name == $0.name})
					.filter({teacher.subject == $0.subject})
					.filter({teacher.roomNum == $0.roomNum})
					.map({$0.blockNum})
				
				builder.blockNums.append(contentsOf: blockNums)
				groupedBlockNums.append(contentsOf: blockNums)
				builder.blockLetter = blockLetter
				builder.lunch = getLunchFromTaughtBlocks(blockLetter, blockNums:builder.blockNums)
				builder.name = teacher.name
				builder.subject = teacher.subject
				builder.roomNum = teacher.roomNum
				tempSavedTeachers.append(builder.build())
				
				builder.blockNums.removeAll()
			}
			
			groupedBlockNums.removeAll(keepingCapacity: true)
			teacherForBlockNum.removeAll(keepingCapacity: true)
		}
		
		savedTeachers = tempSavedTeachers
		toggleEmptyState()
		teacherTable.reloadData()
		view.setNeedsDisplay()
	}
	private func getTeachersForBlock(_ blockLetter:String) -> [Int:TeacherSingleBlock]
	{
		//optional name as you might not have a teacher saved for this block
		var teacherForBlockNum = [Int:TeacherSingleBlock]()
        Block.BLOCK_NUMBERS.forEach({teacherForBlockNum[$0] = Settings.getTeacher(blockLetter: blockLetter, blockNum: $0)})
		return teacherForBlockNum
	}
	private func getLunchFromTaughtBlocks(_ blockLetter:String, blockNums:[Int]) -> Int?
	{
		let lunchBlockNums = blockNums.filter({Block.LUNCH_BLOCK_FOR_DAY.values.contains(blockLetter + String($0))})
        return lunchBlockNums.isEmpty ? nil : Settings.getLunchNum(for: blockLetter)
	}
	private func toggleEmptyState()
	{
		savedTeachers.isEmpty ? teacherTable.setEmptyStateType(.NoTeacherAdded) : teacherTable.hideEmptyState()
	}
}
