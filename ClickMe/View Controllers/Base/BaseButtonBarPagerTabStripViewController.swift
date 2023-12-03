//
//  BaseButtonBarPagerTabStripViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import Foundation
import XLPagerTabStrip

class BaseButtonBarPagerTabStripViewController: ButtonBarPagerTabStripViewController {
    private var observer: NSObjectProtocol?
    var tutorialManager: TutorialManager?
    
    var api: ClickAPI {
        return ClickAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        containerView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        
        settings.style.buttonBarBackgroundColor = themeManager.themeData!.defaultBackground.hexColor
        settings.style.buttonBarItemBackgroundColor = themeManager.themeData!.defaultBackground.hexColor
        settings.style.selectedBarBackgroundColor = themeManager.themeData!.indigo.hexColor
        settings.style.buttonBarItemTitleColor = themeManager.themeData!.textLabel.hexColor
        buttonBarView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        buttonBarView.reloadData()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = themeManager.themeData!.defaultBackground.hexColor
        settings.style.buttonBarItemBackgroundColor = themeManager.themeData!.defaultBackground.hexColor
        settings.style.selectedBarBackgroundColor = themeManager.themeData!.indigo.hexColor
        settings.style.buttonBarItemFont = UIFont(name: "SFUIDisplay-Regular", size: 17.0)!
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = themeManager.themeData!.textLabel.hexColor
        settings.style.buttonBarItemsShouldFillAvailableWidth = true

        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = 10

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = self.themeManager.themeData!.textLabel.hexColor
        }
        delegate = self
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setup()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIViewController.topViewController == self else { return }

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "dark"])
            } else {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "light"])
            }
        }
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
