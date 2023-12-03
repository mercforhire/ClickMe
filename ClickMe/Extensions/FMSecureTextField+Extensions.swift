//
//  FMSecureTextField+Extensions.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-18.
//

import Foundation
import FMSecureTextField

extension FMSecureTextField {
    func applyTheme() {
        let themeData = ThemeManager.shared.themeData!
        
        backgroundColor = themeData.textFieldBackground.hexColor
        textColor = themeData.textLabel.hexColor
        tintColor = themeData.indigo.hexColor
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
}
