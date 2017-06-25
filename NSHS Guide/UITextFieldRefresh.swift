//
//  UITextFieldRefresh.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/9/13.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 A text field with a refresh button gravitating towards the right.
 - important: Set the `refreshFunc` ASAP after initializing, because that's the function that will be called when the user clicks the refresh button
 */
class UITextFieldRefresh:UITextField
{
	var refreshFunc:(()->())?
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		initRefreshButton()
	}
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		initRefreshButton()
	}
    /**
     Sets up a refresh butotn to the right of (but within) the UILabel
     */
	private func initRefreshButton()
	{
		let refreshButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
		refreshButton.setImage(UIImage(named: "ic_refresh")!, for: UIControlState())
        refreshButton.addTarget(self, action: #selector(refreshClicked), for: .touchUpInside)
		
		rightView = refreshButton
		rightViewMode = .always
		clearButtonMode = .never
	}
    /**
     OnClickListener for the refresh button. Calls the provided `refreshFunc`
     */
	func refreshClicked()
	{
		guard refreshFunc != nil else {
			print("UITextFieldRefresh refreshFunc not set")
			return
		}
		
		refreshFunc!()
	}
}
