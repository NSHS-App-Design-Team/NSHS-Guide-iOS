//
//  Teacher.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/6/18.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import Foundation

enum TeacherType
{
	case yourTeacher, yourTeacherNoInfo, otherTeacher, otherTeacherNoInfo
}
protocol Teacher
{
	var name:String { get }
	var info:String? { get }
	func getType() -> TeacherType
}
