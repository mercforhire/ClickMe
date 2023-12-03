//
//  UIButton+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-24.
//

import Foundation
import UIKit

extension UIButton {
    func highlightButton(back: UIColor = ThemeManager.shared.themeData!.indigo.hexColor, text: UIColor = UIColor.white) {
        backgroundColor = back
        setTitleColor(text, for: .normal)
    }
    
    func unhighlightButton(back: UIColor = UIColor.white, text: UIColor = UIColor.black) {
        backgroundColor = back
        setTitleColor(text, for: .normal)
    }
}
