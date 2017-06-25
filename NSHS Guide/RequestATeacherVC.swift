//
//  RequestATeacherVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2016/6/5.
//  Copyright © 2016年 NSHS App Design Team. All rights reserved.
//

import UIKit

class RequestATeacherVC:UITableViewController
{
    @IBOutlet private var firstNameText:UITextField!
    @IBOutlet private var lastNameText:UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    @IBAction func sendTeacherRequest(_ sender: UIBarButtonItem)
    {
        if (firstNameText.text!.isEmpty) {
            Popup.withTitle(String.local("alertErrorTitle"), message: String.local("alertNoFirstName"), presentingClass: self)
            return
        }
        if (lastNameText.text!.isEmpty) {
            Popup.withTitle(String.local("alertErrorTitle"), message: String.local("alertNoLastName"), presentingClass: self)
            return
        }
        
        Internet.sendTeacherRequest(firstName: firstNameText.text!, lastName: lastNameText.text!)
        Popup.withTitle(String.local("alertInfoTitle"), message: String.local("alertTeacherRequestSent"), presentingClass: self, action: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
}
