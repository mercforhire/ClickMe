//
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-05.
//

import Foundation
import UIKit

public enum Theme: Int, Codable {
    case light = 0
    case dark = 1
}

public struct FontTheme: Codable {
    public var weight: String
    public var size: CGFloat
    public var font: String
    
    var fontName: String {
        return "\(font.capitalizingFirstLetter())-\(weight.capitalizingFirstLetter())"
    }
    
    func toFont(overrideSize: CGFloat? = nil) -> UIFont? {
        return UIFont(name: fontName, size: overrideSize ?? size)
    }
    
    init(dict: [String: Any]) {
        weight = dict["weight"] as! String
        size = dict["size"] as! CGFloat
        font = dict["font"] as! String
    }
}

public struct TextLabelTheme: Codable {
    public var textColor: String
    public var font: FontTheme
    
    init(dict: [String: Any]) {
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
    }
}

public struct TabBarTheme: Codable {
    public var selectedColor: String
    public var selectedTextColor: String
    public var unSelectedColor: String
    public var unSelectedTextColor: String
    
    init(dict: [String: Any]) {
        selectedColor = dict["selectedColor"] as! String
        selectedTextColor = dict["selectedTextColor"] as! String
        unSelectedColor = dict["unSelectedColor"] as! String
        unSelectedTextColor = dict["unSelectedTextColor"] as! String
    }
}

public struct NavBarTheme: Codable {
    public var backgroundColor: String
    public var textColor: String
    public var font: FontTheme
    public var barButton: TextLabelTheme
    
    init(dict: [String: Any]) {
        backgroundColor = dict["backgroundColor"] as! String
        textColor = dict["textColor"] as! String
        font = FontTheme(dict: dict["font"] as! [String : Any])
        barButton = TextLabelTheme(dict: dict["BarButton"] as! [String : Any])
    }
}

public struct TutorialTheme: Codable {
    public var textColor: String
    public var bubbleBackgroundColor: String
    
    init(dict: [String: Any]) {
        textColor = dict["textColor"] as! String
        bubbleBackgroundColor = dict["bubbleBackgroundColor"] as! String
    }
}

public struct ThemeData: Codable {
    public var defaultBackground: String
    public var whiteBackground: String
    public var textLabel: String
    public var textFieldBackground: String
    public var indigo: String
    public var gold: String
    public var darkLabel: String
    public var topicName: String
    public var chatBox: String
    public var greenSendIcon: String
    public var tabBarTheme: TabBarTheme
    public var navBarTheme: NavBarTheme
    public var tutorialTheme: TutorialTheme
    
    public init(dict: [String: Any]) {
        defaultBackground = dict["defaultBackground"] as! String
        whiteBackground = dict["whiteBackground"] as! String
        textLabel = dict["textLabel"] as! String
        textFieldBackground = dict["textFieldBackground"] as! String
        indigo = dict["indigo"] as! String
        gold = dict["gold"] as! String
        darkLabel = dict["darkLabel"] as! String
        topicName = dict["topicName"] as! String
        chatBox = dict["chatBox"] as! String
        greenSendIcon = dict["greenSendIcon"] as! String
        tabBarTheme = TabBarTheme(dict: dict["TabBar"] as! [String : Any])
        navBarTheme = NavBarTheme(dict: dict["NavBar"] as! [String : Any])
        tutorialTheme = TutorialTheme(dict: dict["Tutorial"] as! [String : Any])
    }
}
