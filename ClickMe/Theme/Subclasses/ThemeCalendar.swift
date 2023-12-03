//
//  ThemeCalendar.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-08-01.
//

import UIKit
import FSCalendar

class ThemeCalendar: FSCalendar {
    private var observer: NSObjectProtocol?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func setupUI() {
        backgroundColor = themeManager.themeData!.indigo.hexColor
        
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

class ThemeWhiteCalendar: FSCalendar {
    private var observer: NSObjectProtocol?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func setupUI() {
        backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        
        self.appearance.headerTitleColor = themeManager.themeData!.textLabel.hexColor
        
        self.headerHeight = 40.0
        self.weekdayHeight = 35.0
        self.appearance.weekdayTextColor = themeManager.themeData!.textLabel.hexColor
        
        self.appearance.titleTodayColor = themeManager.themeData!.textLabel.hexColor
        self.appearance.titleDefaultColor = themeManager.themeData!.textLabel.hexColor
        self.appearance.titleWeekendColor = themeManager.themeData!.textLabel.hexColor
        self.appearance.titlePlaceholderColor = themeManager.themeData!.textLabel.hexColor
        self.appearance.headerMinimumDissolvedAlpha = 0.0
        self.appearance.todayColor = .clear
        configureAppearance()
        
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
