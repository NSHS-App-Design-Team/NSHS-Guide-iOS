import UIKit

/**
 This class is used solely to determine which tab should open by default by `Settings`.
 - important: Do not change the index of any of these tabs or you will break the app across releases; they are irrelevant numbers chosen to represent each tab
 */
enum Tabs:Int
{
	case absentTeachers = 1, blocks
    
    func toString() -> String
    {
        switch (self)
        {
        case .absentTeachers:
            return String.local("absentTeachers")
        case .blocks:
            return String.local("blocks")
        }
    }
}
