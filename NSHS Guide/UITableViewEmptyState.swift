//
//  UITableViewEmptyState.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/9/5.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 A UITableView that displays a custom image with custom text when it is empty
 */
class UITableViewEmptyState:UITableView
{
    /**
     The current available types of empty states, with the image resource ID AND localized string key as the rawValue.
     - important: If you want to add a new empty state, create an image in Images.xcassets and write the custom text that will appear in Localizable.strings. The resources name of the image and the key to the localized string should be the same; they should be set as the rawValue of the new `Types`
     */
	enum Types:String
	{
		case NoTeacherAdded = "empty_state_no_teacher_added"
		case NoAbsentTeacher = "empty_state_no_absent_teacher"
		case NoSchool = "empty_state_no_school"
	}
	
	private var emptyState:UIView!
	private var emptyStateLoaded = false
	
	/*
	OVERRIDING INITIALIZERS
	*/
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		initEmptyState()
	}
	override init(frame: CGRect, style: UITableViewStyle)
	{
		super.init(frame: frame, style: style)
		initEmptyState()
	}
    /**
     Set up the emtpy state TableView while we still do not know what image or text to display.
     */
	private func initEmptyState()
	{
		emptyState = UIView(frame: frame)
		emptyState.isHidden = true	//defaults to hidden
		backgroundView = emptyState
	}
	
    /**
     Hides the empty state.
     */
	func hideEmptyState()
	{
		emptyState.isHidden = true
	}
    /**
     Tells the empty state what image and text to display according to the given type, then SHOWS the empty state. This method will load the images and text if they haven't been loaded yet. Call this method whenever you want the empty state to show.
     - parameter type: The type detailing what image/text to display for the empty state
     */
	func setEmptyStateType(_ type:Types)
	{
		//don't do anything if empty state is already showing
		guard emptyState.isHidden else {
			return
		}
		emptyState.isHidden = false
		//if the empty state was already loaded, no need to waste resources to recreate one
		guard !emptyStateLoaded else {
			return
		}
		emptyStateLoaded = true
		
		let image = UIImage(named: type.rawValue)
		let text = String.local(type.rawValue)
		
		guard image != nil else {
			print("empty state image not added to resources, type: \(type.rawValue)")
			return
		}
		setImageViewAndLabel(image: image!, text: text)
	}
    //the following methods are private and self explanatory, so not documentation will be provided (sorry)
	private func setImageViewAndLabel(image:UIImage, text:String)
	{
		let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
		let label = UILabel()
		label.text = text
		setUpLabel(label)
		
		let container = UIView()
		container.addSubview(imageView)
		container.addSubview(label)
		emptyState.addSubview(container)
        setConstraints(container: container, image:imageView, label:label)
	}
	private func setUpLabel(_ label:UILabel)
	{
		label.textColor = UIColor.gray
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20)
		label.numberOfLines = 2
	}
	private func setConstraints(container:UIView, image:UIImageView, label:UILabel)
	{
		let views = [image, label, container]
		views.forEach({$0.translatesAutoresizingMaskIntoConstraints = false})
		
		//center image in container
		container.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0))
		//center label in container, place under image
		container.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0))
		container.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: image, attribute: .bottom, multiplier: 1, constant: LayoutConstants.margin.rawValue))
		//set container dimensions to fit children snuggly
		container.addConstraint(NSLayoutConstraint(item: image, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0))
		container.addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1, constant: 0))
		container.addConstraint(NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1, constant: 0))
		container.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0))
		//center container
		emptyState.addConstraint(NSLayoutConstraint(item: container, attribute: .centerY, relatedBy: .equal, toItem: emptyState, attribute: .centerY, multiplier: 1, constant: 0))
		emptyState.addConstraint(NSLayoutConstraint(item: container, attribute: .centerX, relatedBy: .equal, toItem: emptyState, attribute: .centerX, multiplier: 1, constant: 0))
	}
}
