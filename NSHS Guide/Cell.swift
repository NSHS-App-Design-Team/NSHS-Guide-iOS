//
//  Cell.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/2/12.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 Since iOS does not support circular backgrounds, this class is how we turn squares into circles for the signature block image background.
 */
class Cell
{
	//suppress default constructor for noninstantiability
	private init(){}
	
    /**
     Makes the given view's background circular.
     - paramter view: The view whose background should become a circle
     */
	static func round(_ view:UIView)
	{
		view.layer.cornerRadius = view.frame.width / 2
		view.layer.masksToBounds = false
		view.layer.rasterizationScale = UIScreen.main.scale
		view.layer.shouldRasterize = true
	}
    /**
     Colors the given view's background the specified color
     - parameters:
        - color: The color the background should be
        - view: The view whose background should be colored
     */
	static func color(_ color:AppColors, view:UIView)
	{
		view.layer.backgroundColor = color.cgColor()
	}
    /**
     Colors the given view's background given the block letter and desired color type
     - parameters:
        - blockLetter: The block letter
        - colorType: The color type according to `AppColors`.`Types`
        - view: The view whose background should be colored
     */
    static func color(accordingTo blockLetter:String, colorType:AppColors.Types, view:UIView)
	{
        color(AppColors.ofType(colorType, letter: blockLetter), view: view)
	}
    /**
     Colors the given views' backgrounds, each according to the given formula (yay functional programming!)
     - paramters:
        - formula: Function determining what color a UITextField should have
        - views: The views whose background should be colored
     */
    static func color(accordingTo formula:(UITextField) -> (AppColors), views:[UITextField])
    {
        views.forEach({$0.layer.backgroundColor = formula($0).cgColor()})
    }
}
