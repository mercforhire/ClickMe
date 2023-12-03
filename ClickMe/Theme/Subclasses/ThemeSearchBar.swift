//
//  ThemeSearchBar.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-09-12.
//

import UIKit

class ThemeSearchBar: UISearchBar {

    private var observer: NSObjectProtocol?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    func setupUI() {
        barTintColor = themeManager.themeData!.defaultBackground.hexColor
        backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        searchTextField.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        searchTextField.textColor = themeManager.themeData!.textLabel.hexColor
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }

}
