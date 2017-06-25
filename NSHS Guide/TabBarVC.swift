//
//  TabBarVC.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/8/6.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

class TabBarVC:UITabBarController, UINavigationControllerDelegate
{
	override func viewDidLoad()
	{
        super.viewDidLoad()
		let classOfInitialVC = classFromTab(Settings.getLandingPage())
		selectInitVC(classOfInitialVC)
		
		//disable the edit button in moreNavigationController
		customizableViewControllers = nil
	}
	private func classFromTab(_ tab:Tabs) -> UIViewController.Type
	{
		switch (tab)
		{
		case .absentTeachers:
			return AbsentTeachersVC.self
		case .blocks:
			return BlocksVC.self
		}
	}
	private func selectInitVC(_ type:UIViewController.Type)
	{
		for i in 0..<viewControllers!.count
		{
			if let navController = viewControllers![i] as? UINavigationController
			{
				if (type(of: navController.topViewController!) === type)
				{
					selectedIndex = i
					return
				}
			}
		}
	}
}
