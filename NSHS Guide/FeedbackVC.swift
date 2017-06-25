//
//  FeedbackVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/7/26.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class FeedbackVC:UITableViewController
{
	@IBOutlet private var nameText:UITextField!
	@IBOutlet private var emailText:UITextField!
	@IBOutlet private var feedbackText:UITextView!
	private let SECRET_CODE_NAME = "hoover"
	private let SECRET_CODE_FEEDBACK = "hawley smoot"
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		deleteFeedbackTextLeftPadding()
        setSavedNameAndEmail()
	}
	private func deleteFeedbackTextLeftPadding()
	{
		feedbackText.textContainer.lineFragmentPadding = 0
	}
    private func setSavedNameAndEmail()
    {
        if let name = Settings.getName()
        {
            nameText.text = name
        }
        if let email = Settings.getEmail()
        {
            emailText.text = email
        }
    }
	@IBAction func sendFeedback(_ sender: UIBarButtonItem)
	{
		guard !nameText.text!.isEmpty else {
			Popup.withTitle(String.local("alertErrorTitle"), message: String.local("alertNoName"), presentingClass: self)
			return
		}
		guard !feedbackText.text!.isEmpty else {
			Popup.withTitle(String.local("alertErrorTitle"), message: String.local("alertNoFeedback"), presentingClass: self)
			return
		}
		guard !isSecretCode() else {
			Popup.withTitle(String.local("alertInfoTitle"), message: String.local("alertDeveloperModeOn"), presentingClass: self)
			Settings.setDeveloperModeOn(true)
			showRegId()
			return
		}
		
        Settings.setName(nameText.text!)
        if let email = emailText.text
        {
            Settings.setEmail(email)
        }
		Internet.sendFeedback(name: nameText.text!, email: emailText.text!, feedback: feedbackText.text)
        Popup.withTitle(String.local("alertInfoTitle"), message: String.local("alertFeedbackSent"), presentingClass: self, action:{
            self.navigationController?.popViewController(animated: true)
        })
	}
	private func isSecretCode() -> Bool
	{
		return nameText.text!.lowercased() == SECRET_CODE_NAME && feedbackText.text.lowercased() == SECRET_CODE_FEEDBACK
	}
	private func showRegId()
	{
		guard let regId = Settings.getRegId() else {
			feedbackText.text = "Couldn't retrieve regID"
			return
		}
		feedbackText.text = regId
	}
}
