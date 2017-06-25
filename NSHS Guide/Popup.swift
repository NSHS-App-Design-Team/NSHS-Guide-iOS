//
//  Popup.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/5/24.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 Presents popups to the user.
 */
class Popup
{
	//suppress default constructor for noninstantiability
	private init(){}
    
    /**
     Shows a popup with an "OK" button with the given information.
     - parameters:
        - title: Title of the popup
        - message: The body of the popup
        - presentingClass: The ViewController that this popup appears on
     */
	static func withTitle(_ title:String, message:String, presentingClass:UIViewController)
	{
		withTitle(title, message: message, presentingClass: presentingClass, action: nil)
	}
    /**
     Shows a popup with an "OK" button with the given information. An action will be performed once the button is clicked
     - parameters:
     - title: Title of the popup
     - message: The body of the popup
     - presentingClass: The ViewController that this popup appears on
     - action: The action to be performed once the "OK" button is clicked
     */
    static func withTitle(_ title:String, message:String, presentingClass:UIViewController, action:(()->())?)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(a) in action?()}))
        presentingClass.present(alert, animated: true, completion: nil)
    }
}
