//
//  GlobalExtensions.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/6/17.
//  Copyright © 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

extension String
{
	subscript (i: Int) -> Character
	{
		return self[self.characters.index(self.startIndex, offsetBy: i)]
	}
	subscript (i: Int) -> String
	{
		return String(self[i] as Character)
	}
	subscript (r: Range<Int>) -> String
	{
		return substring(with: characters.index(startIndex, offsetBy: r.lowerBound)..<characters.index(startIndex, offsetBy: r.upperBound))
	}
    /**
     Returns the localized version with the key given. The list of key-value pairs are in the file Localizable.strings. This is to prepare for internationalization.
     - parameter key: The key to the localized string
     - returns: String in the user's native language for the given key
     */
    static func local(_ key:String) -> String
    {
        return NSLocalizedString(key, comment: "")
    }
}

extension UILabel
{
    /**
     Resizes the UILabel so that everything within fits just into the bounds given, with the distinction of gravitating towards the right (like in Arabic) instead of the left.
     */
	func sizeToFitRight()
	{
		let beforeFrame = frame
		sizeToFit()
		let afterFrame = frame
		frame = CGRect(x: beforeFrame.origin.x + beforeFrame.size.width - afterFrame.size.width, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
	}
}
