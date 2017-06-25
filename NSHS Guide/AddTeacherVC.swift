//
//  AddTeacherVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/2/9.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class AddTeacherVC:UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet private var blockImage: UITextField!
    @IBOutlet private var block1Image: UITextField!
    @IBOutlet private var block2Image: UITextField!
    @IBOutlet private var block3Image: UITextField!
    @IBOutlet private var block4Image: UITextField!
    private var blockNumImages:[Int:UITextField]!
    @IBOutlet private var teacherNameText: UITextField!
    @IBOutlet private var lunch1Image: UITextField!
    @IBOutlet private var lunch2Image: UITextField!
    @IBOutlet private var lunch3Image: UITextField!
	private var lunchNumImages:[Int:UITextField]!
	@IBOutlet private var lunchView: UIView!
	@IBOutlet private var lunchViewHeight: NSLayoutConstraint!
	@IBOutlet private var lunchViewTopMargin: NSLayoutConstraint!
	@IBOutlet private var aBlockImage: UITextField!
	@IBOutlet private var bBlockImage: UITextField!
	@IBOutlet private var cBlockImage: UITextField!
	@IBOutlet private var dBlockImage: UITextField!
	@IBOutlet private var eBlockImage: UITextField!
	@IBOutlet private var fBlockImage: UITextField!
	@IBOutlet private var gBlockImage: UITextField!
	@IBOutlet private var hBlockImage: UITextField!
	@IBOutlet private var jBlockImage: UITextField!
	private var blockLetterImages:[UITextField]!
	
	@IBOutlet private var subjectText: UITextField!
	@IBOutlet private var roomNumText: UITextField!
	@IBOutlet private var teacherAutoCompleteText: UITextFieldRefresh!
	private var textFields:[UITextField]!
	@IBOutlet private var teacherAutoCompleteTableView: UITableView!
	@IBOutlet private var selectBlockLetterView: UIView!
	@IBOutlet private var scrollView: UIScrollView!
	
	static let SEGUE_ID = "addTeacher"
	
	private var parentListResetMethod:(() -> ())?
	private var editedTeacher:TeacherYours?
	private var teacherBuilder = TeacherYours.Builder()
	
	//teacher list retrieved from TeacherListParser
    private var teachersList = Settings.getTeachersList()
	private var filteredTeachersList:[String] = []
    
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		storeImagesInArrays()
		storeTextFieldsInArray()
		roundImages()
        Cell.color(accordingTo: {AppColors.ofType(.normal, letter: $0.text!)}, views: blockLetterImages)
		deleteLunch()	//get rid of spacing for lunch blocks first
		
		//do these things if we're editing a teacher (user pressed a teacher from YourTeachersVC)
		editedTeacher == nil ? showDefaultTeacher() : showEditedTeacher()
		
		//teachers list
		sync()
		teacherAutoCompleteText.refreshFunc = getTeachersList
	}
	private func storeImagesInArrays()
	{
		blockNumImages = [1:block1Image, 2:block2Image, 3:block3Image, 4:block4Image]
		lunchNumImages = [1:lunch1Image, 2:lunch2Image, 3:lunch3Image]
		blockLetterImages = [aBlockImage, bBlockImage, cBlockImage, dBlockImage, eBlockImage, fBlockImage, gBlockImage, hBlockImage, jBlockImage]
	}
	private func storeTextFieldsInArray()
	{
		textFields = [teacherAutoCompleteText, subjectText, roomNumText]
	}
	private func roundImages()
	{
        blockNumImages.values.forEach({Cell.round($0)})
        lunchNumImages.values.forEach({Cell.round($0)})
        blockLetterImages.forEach({Cell.round($0)})
		Cell.round(blockImage)
	}
	private func showEditedTeacher()
	{
		teacherAutoCompleteText.text = editedTeacher!.name
		subjectText.text = editedTeacher!.subject
		roomNumText.text = editedTeacher!.roomNum
		setBlockLetter(editedTeacher!.blockLetter)
		setBlockNums(editedTeacher!.blockNums, blockLetter: editedTeacher!.blockLetter)
		setLunch(editedTeacher!.lunch)
	}
	private func showDefaultTeacher()
	{
		let defaultBlockLetter = Block.BLOCK_LETTERS[0]
		setBlockLetter(defaultBlockLetter)
		setBlockNums(nil, blockLetter: defaultBlockLetter)
	}
	private func showNoTeachersDialog()
	{
		Popup.withTitle(String.local("alertNoTeachersList"), message: String.local("alertMessageNoTeachersList"), presentingClass: self)
	}
	private func sync()
	{
		if (Settings.isSyncOn())
		{
			getTeachersList()
		}
	}
	private func getTeachersList()
	{
		Internet.queryTeachersList(
		completion: {
			[unowned self] () -> () in
			self.teachersList = Settings.getTeachersList()
		})
	}
    func saveTeacher()
    {
		teacherBuilder.name = teacherAutoCompleteText.text
		teacherBuilder.subject = subjectText.text
		teacherBuilder.roomNum = roomNumText.text
		
		//check if info is enough for saving
		guard !teacherBuilder.name!.isEmpty else {
			Popup.withTitle(String.local("alertErrorTitle"), message: String.local("alertNoTeacher"), presentingClass: self)
			return
		}
		guard !teacherBuilder.blockNums.isEmpty else {
			Popup.withTitle(String.local("alertErrorTitle"), message: String.local("alertNoBlockNumSelected"), presentingClass: self)
			return
		}
		guard teachersList!.contains(teacherBuilder.name!) else {
			Popup.withTitle(String.local("alertErrorTitle"), message: teacherBuilder.name! + String.local("alertTeacherNonexistent"), presentingClass: self)
			return
		}
		
		editedTeacher?.remove()
		teacherBuilder.build().save()
		returnToParent()
    }
	private func returnToParent()
	{
		Settings.finishSavingImmediately()
		TeacherManager.absentTeachers()
		parentListResetMethod?()
		navigationController?.popViewController(animated: true)
	}
	
	/*
	SETTING FUNCTIONS THAT STORE INFO IN TEACHER_BUILDER & CHANGE UI
	*/
	private func setBlockLetter(_ blockLetter:String)
	{
		teacherBuilder.blockLetter = blockLetter
		blockImage.text = blockLetter
		Cell.color(accordingTo: blockLetter, colorType: .normal, view: blockImage)
	}
	private func toggleBlockNum(_ blockNum:Int)
	{
		if (teacherBuilder.blockNums.contains(blockNum))
		{
			teacherBuilder.blockNums.remove(at: teacherBuilder.blockNums.index(of: blockNum)!)
			Cell.color(accordingTo: teacherBuilder.blockLetter!, colorType: .light, view: blockNumImages[blockNum]!)
		}
		else
		{
			teacherBuilder.blockNums.append(blockNum)
			Cell.color(accordingTo: teacherBuilder.blockLetter!, colorType: .normal, view: blockNumImages[blockNum]!)
		}
	}
	private func setBlockNums(_ blockNums:[Int]?, blockLetter:String)
	{
		blockNumImages.values.forEach({$0.text = blockLetter + $0.text!.substring(from: $0.text!.characters.index(before: $0.text!.endIndex))})
		//fade all cells by default
        blockNumImages.values.forEach({Cell.color(accordingTo: blockLetter, colorType: .light, view: $0)})
		
		guard blockNums != nil else {
			return
		}
		teacherBuilder.blockNums = blockNums!
		//brighten color of those cells we want
		blockNums!.forEach({Cell.color(accordingTo: blockLetter, colorType: .normal, view: self.blockNumImages[$0]!)})
	}
	private func toggleLunch()
	{
		//if no block nums are selected, there are no lunch blocks
		guard !teacherBuilder.blockNums.isEmpty else {
			deleteLunch()
			return
		}
		
		for blockNum in teacherBuilder.blockNums
		{
			let block = "\(teacherBuilder.blockLetter!)\(blockNum)"
			guard Block.LUNCH_BLOCK_FOR_DAY.values.contains(block) else {
				continue
			}
			//only set new lunch if new blockNum contains lunch & there wasn't a lunch
			guard teacherBuilder.lunch == nil else {
				return
			}
			
			setLunch(editedTeacher?.lunch ?? 1)
			//exit function so lunch isn't deleted
			return
		}
		deleteLunch()
	}
	private func setLunch(_ lunchNum:Int?)
	{
		guard lunchNum != nil else {
			return
		}
		
		lunchView.isHidden = false
		lunchViewHeight.constant = LayoutConstants.blockImageSize.rawValue
		lunchViewTopMargin.constant = LayoutConstants.margin.rawValue
		teacherBuilder.lunch = lunchNum
        lunchNumImages.values.forEach({Cell.color(AppColors.blueGreyLight, view: $0)})
		Cell.color(AppColors.blueGrey, view: lunchNumImages[lunchNum!]!)
	}
	private func deleteLunch()
	{
		lunchView.isHidden = true
		lunchViewHeight.constant = 0
		lunchViewTopMargin.constant = 0
		teacherBuilder.lunch = nil
	}
	
	/*
	TEXTFIELDS AND KEYBOARD
	*/
	//so the buttons with text in them don't allow the text to be edited (like blockImage)
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
	{
		switch (textField)
		{
		case let textField where textFields.contains(textField):
			return true
		case blockImage:
			blockImagePressed(sender: textField)
			return false
		case let image where blockNumImages.values.contains(image):
			blockNumImageSelected(sender: image)
			return false
		case let image where lunchNumImages.values.contains(image):
			lunchNumImageSelected(sender: image)
			return false
		case let image where blockLetterImages.contains(image):
			blockLetterSelected(sender: image)
			return false
		default:
			print("add teacher textfield that we didn't account for was clicked")
			return false
		}
	}
	//what happens when "Next" or "Done" is pressed, tag is set in storyboard
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		let nextTage = textField.tag + 1;
		// Try to find next responder
		let nextResponder = textField.superview?.viewWithTag(nextTage) as UIResponder!
		
		if (nextResponder != nil)
		{
			nextResponder?.becomeFirstResponder()
		}
		else
		{
			textField.resignFirstResponder()
			saveTeacher()
		}
		return false
	}
	//gets rid of keyboard when user clicks on a random spot on the screen that isn't the keyboard
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		textFields.forEach({$0.resignFirstResponder()})
		super.touchesBegan(touches, with: event)
	}
	//make sure keyboard doesn't cover textfields that we're typing in (namely teacher text)
	func textFieldDidBeginEditing(_ textField: UITextField)
	{
		let scrollPoint = CGPoint(x: 0, y: textField.frame.origin.y - LayoutConstants.margin.rawValue)
		scrollView.setContentOffset(scrollPoint, animated: true)
	}
	func textFieldDidEndEditing(_ textField: UITextField)
	{
		scrollView.setContentOffset(CGPoint.zero, animated: true)
	}
	
	/*
	IBACTION
	*/
	private func blockImagePressed(sender: UITextField)
	{
		showAllBlocksForSelection(true)
	}
	//allows the user to select a different block when blockImage is clicked
	private func showAllBlocksForSelection(_ shouldShow:Bool)
	{
		selectBlockLetterView.isHidden = !shouldShow
		blockImage.isHidden = shouldShow
	}
	private func blockLetterSelected(sender:UITextField)
	{
		let blockLetter = sender.text!
		
		showAllBlocksForSelection(false)
		setBlockLetter(blockLetter)
		setBlockNums(teacherBuilder.blockNums, blockLetter: blockLetter)
		toggleLunch()
	}
	private func blockNumImageSelected(sender: UITextField)
	{
		//find the number of this view so we can check the bool array to see if it's currently on
		let blockNum = Int(sender.text!.substring(from: sender.text!.characters.index(before: sender.text!.endIndex)))!
		
		//change its color depending on whether it's on or not
		toggleBlockNum(blockNum)
		toggleLunch()
	}
	private func lunchNumImageSelected(sender: UITextField)
	{
		setLunch(Int(sender.text!)!)
	}
	@IBAction func teacherNameFieldEdited(_ sender: UITextField)
	{
		guard teachersList != nil else {
			showNoTeachersDialog()
			return
		}
		
		//filter through teachers
		if (!sender.text!.isEmpty)
		{
			filteredTeachersList = teachersList!.filter({$0.lowercased().hasPrefix(sender.text!.lowercased())})
			teacherAutoCompleteTableView.reloadData()
			teacherAutoCompleteTableView.isHidden = false
		}
		else
		{
			//hide the view if the user isn't inputting anything anymore
			teacherAutoCompleteTableView.isHidden = true
		}
	}
	@IBAction func savePressed(_ sender: UIBarButtonItem)
	{
		saveTeacher()
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
		return filteredTeachersList.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "teacherAutoCompleteCell", for: indexPath) 
		cell.textLabel?.text = filteredTeachersList[indexPath.row]
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		teacherAutoCompleteText.text = filteredTeachersList[indexPath.row]
		teacherAutoCompleteText.resignFirstResponder()
		teacherAutoCompleteTableView.isHidden = true
	}
	
	/*
	SEGUE METHODS CALLED BY PARENT
	*/
	func setUpdatableData(resetMethod:@escaping () -> (), teacherToEdit:TeacherYours?)
	{
		parentListResetMethod = resetMethod
		editedTeacher = teacherToEdit
	}
}
