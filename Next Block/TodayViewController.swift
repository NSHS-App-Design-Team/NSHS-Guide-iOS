//
//  TodayViewController.swift
//  Next Block
//
//  Created by Yung Chang Chu on 2015/6/6.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding
{
	//during normal school time
	@IBOutlet var blockImage: UITextField!
	@IBOutlet var teacherNameText: UILabel!
	@IBOutlet var timeText: UILabel!
	//during lunch block
	@IBOutlet var _teacherNameText:UILabel!
	@IBOutlet var _timeText:UILabel!
	@IBOutlet var _lunchText:UILabel!
	@IBOutlet var _lunchTimeText:UILabel!
	//once school is over
	@IBOutlet var schoolsOverText: UILabel!
        
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
        preferredContentSize = CGSize(width: view.bounds.size.width, height: LayoutConstants.listOneLineHeight.rawValue)
		Cell.round(blockImage)
		
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
	func handleTap()
	{
		//open the app on tap
		extensionContext?.open(URL(string: "nshsguide://")!, completionHandler: nil)
	}
	//gets rid of default bottom margin
	func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets
	{
		let margin = UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left, 0, defaultMarginInsets.right)
		return margin
	}
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
	{
		populateWidget()
		completionHandler(NCUpdateResult.newData)
	}
	private func populateWidget()
	{
		if let block = findCurrentBlock()
		{
			block.isLunchBlock ? formatLunchBlock(block) : formalNormalBlock(block)
		}
		else
		{
			formatSchoolsOver()
		}
	}
	//returns nil if nothing should show
	private func findCurrentBlock() -> Block?
	{
        guard let blocksForToday = TeacherManager.blocks(for: LocalDate()) else {
			//must be weekend
			return nil
		}
		//timeAdjust - 5 due to nature of checking against the end of a block
		let time = Time.add(startTime: Time(), minutesToAdd: Settings.getWidgetTimeAdjust() - 5)
		let futureBlocks = blocksForToday.filter({$0.endTime >= time})
		return futureBlocks.first
	}
	
	/*
	MAIN FORMATTING FUNCTIONS
	*/
	private func formalNormalBlock(_ block:Block)
	{
		formatBlockImage(block)
        
        let textAndRoomNum = TeacherManager.teacherTextAndRoomNumForBlock(block)
		teacherNameText.text = textAndRoomNum.text
		
		if let roomNum = textAndRoomNum.roomNum
		{
			_timeText.text = block.getTimeString()
			_lunchTimeText.text = String.local("roomNum") + roomNum
			hideViews(false, views: blockImage, teacherNameText, _timeText, _lunchTimeText)
			hideViews(true, views: _teacherNameText, timeText, _lunchText, schoolsOverText)
		}
		else
		{
			timeText.text = block.getTimeString()
			hideViews(false, views: blockImage, timeText, teacherNameText)
			hideViews(true, views: _teacherNameText, _timeText, _lunchText, _lunchTimeText, schoolsOverText)
		}
	}
	private func formatLunchBlock(_ block:Block)
	{
        let textAndRoomNum = TeacherManager.teacherTextAndRoomNumForBlock(block)
		if let roomNum = textAndRoomNum.roomNum
		{
			let roomNumText = String.local("roomNum") + roomNum
			_timeText.text = "\(block.getTimeString()), \(roomNumText)"
		}
		else
		{
			_timeText.text = block.getTimeString()
		}
		formatBlockImage(block)
		_teacherNameText.text = textAndRoomNum.text
		
        let lunch = Settings.getLunchNum(for: block.letter)
		let lunchBlock = Block.createLunch(lunch, classBlock: block)
		_lunchText.text = String.local("\(lunch)Lunch")
		_lunchTimeText.text = lunchBlock.getTimeString()
		
		hideViews(false, views: blockImage, _teacherNameText, _timeText, _lunchText, _lunchTimeText)
		hideViews(true, views: teacherNameText, timeText, schoolsOverText)
	}
	private func formatSchoolsOver()
	{
		hideViews(false, views: schoolsOverText)
		hideViews(true, views: blockImage, teacherNameText, timeText, _teacherNameText, _timeText, _lunchText, _lunchTimeText)
	}
	
	/*
	HELPER FORMATTING FUNCTIONS
	*/
	private func formatBlockImage(_ block:Block)
	{
		blockImage.text = block.letter
        Cell.color(accordingTo: block.letter, colorType: .normal, view: blockImage)
	}
	private func hideViews(_ shouldHide:Bool, views:UIView...)
	{
		views.forEach({$0.isHidden = shouldHide})
	}
}
