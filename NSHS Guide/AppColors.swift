//
//  AppColors.swift
//  NSHS Guide
//
//  Created by Yung Chang Chu on 2015/3/15.
//  Copyright (c) 2015年 NSHS App Design Team. All rights reserved.
//

import UIKit

/**
 This class stores all the Material Design colors used within the app.
 */
enum AppColors:UInt32
{
    /**
     3 variations (in darkness) of the same color.
     */
    enum Types
    {
        case dark, normal, light
    }
    
    case emptyStateBg = 0x888888
    case white = 0xffffff
    
    case colorPrimary = 0x3f51b5
    case colorPrimaryDark = 0x303f9f
    case colorPrimaryLight = 0xe8eaf6
    case accent = 0xff6d00
    case accentDark = 0xe65100
    case redDark = 0xe93230
    case redLight = 0xffebee
    case red = 0xf16033
    case pinkDark = 0xea3b66
    case pinkLight = 0xfce4ec
    case pink = 0xf06292
    case purpleDark = 0x9e3eb2
    case purpleLight = 0xf3e5f5
    case purple = 0xba68c8
    case blueDark = 0x2881f1
    case blueLight = 0xe3f2fd
    case blue = 0x42a5f5
    case cyanDark = 0x00a1c3
    case cyanLight = 0xe0f7fa
    case cyan = 0x00bcd4
    case tealDark = 0x178272
    case tealLight = 0xe0f2f1
    case teal = 0x26a69a
    case lightGreenDark = 0x5dab2c
    case lightGreenLight = 0xf1f8e9
    case lightGreen = 0x8bc34a
    case amberDark = 0xffc42f
    case amberLight = 0xfbf4de
    case amber = 0xffd54f
    case orangeDark = 0xff8926
    case orangeLight = 0xfbe9e7
    case orange = 0xffab40
    case blueGreyDark = 0x64808e
    case blueGreyLight = 0xdae1e4
    case blueGrey = 0x90a4ae
    
    /**
     - returns: Returns a UIColor object
     */
    func uicolor() -> UIColor
    {
        let red = CGFloat((rawValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rawValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rawValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    /**
     - returns: Returns a CGColor object
     */
    func cgColor() -> CGColor
    {
        return uicolor().cgColor
    }
    /**
     Returns the correct color of the given type for the given block letter
     - parameters
        - type: The color type
        - letter: The block letter
     - returns: Color used for the block letter
     */
    static func ofType(_ type:Types, letter: String) -> AppColors
    {
        switch type
        {
        case .light:
            return light(for: letter)
        case .normal:
            return normal(for: letter)
        case .dark:
            return dark(for: letter)
        }
    }
    /**
     Returns the light color used for the specified block letter within the app. Blue grey is used by default if the block letter is irregular (lunch block or special schedule).
     - parameter letter: The block letter
     - returns: Light color used for the block letter
     */
    private static func light(for letter:String) -> AppColors
    {
        switch (letter)
        {
        case Block.BLOCK_LETTERS[0]:
            return .redLight
        case Block.BLOCK_LETTERS[1]:
            return .pinkLight
        case Block.BLOCK_LETTERS[2]:
            return .purpleLight
        case Block.BLOCK_LETTERS[3]:
            return .blueLight
        case Block.BLOCK_LETTERS[4]:
            return .cyanLight
        case Block.BLOCK_LETTERS[5]:
            return .tealLight
        case Block.BLOCK_LETTERS[6]:
            return .lightGreenLight
        case Block.BLOCK_LETTERS[7]:
            return .amberLight
        case Block.BLOCK_LETTERS[8]:
            return .orangeLight
        default:
            return .blueGreyLight
        }
    }
    /**
     Returns the normal color used for the specified block letter within the app. Blue grey is used by default if the block letter is irregular (lunch block or special schedule).
     - parameter letter: The block letter
     - returns: Normal color used for the block letter
     */
    private static func normal(for letter:String) -> AppColors
    {
        switch (letter)
        {
        case Block.BLOCK_LETTERS[0]:
            return .red
        case Block.BLOCK_LETTERS[1]:
            return .pink
        case Block.BLOCK_LETTERS[2]:
            return .purple
        case Block.BLOCK_LETTERS[3]:
            return .blue
        case Block.BLOCK_LETTERS[4]:
            return .cyan
        case Block.BLOCK_LETTERS[5]:
            return .teal
        case Block.BLOCK_LETTERS[6]:
            return .lightGreen
        case Block.BLOCK_LETTERS[7]:
            return .amber
        case Block.BLOCK_LETTERS[8]:
            return .orange
        default:
            return .blueGrey
        }
    }
    /**
     Returns the dark color used for the specified block letter within the app. Blue grey is used by default if the block letter is irregular (lunch block or special schedule).
     - parameter letter: The block letter
     - returns: Dark color used for the block letter
     */
    private static func dark(for letter:String) -> AppColors
    {
        switch (letter)
        {
        case Block.BLOCK_LETTERS[0]:
            return .redDark
        case Block.BLOCK_LETTERS[1]:
            return .pinkDark
        case Block.BLOCK_LETTERS[2]:
            return .purpleDark
        case Block.BLOCK_LETTERS[3]:
            return .blueDark
        case Block.BLOCK_LETTERS[4]:
            return .cyanDark
        case Block.BLOCK_LETTERS[5]:
            return .tealDark
        case Block.BLOCK_LETTERS[6]:
            return .lightGreenDark
        case Block.BLOCK_LETTERS[7]:
            return .amberDark
        case Block.BLOCK_LETTERS[8]:
            return .orangeDark
        default:
            return .blueGreyDark
        }
    }
}
