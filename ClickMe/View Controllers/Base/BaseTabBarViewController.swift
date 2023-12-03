//
//  BaseTabBarViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-27.
//

import UIKit

class BaseTabBarViewController: UITabBarController {
    var api: ClickAPI {
        return ClickAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func handlePresentScheduleView(userInfo: [AnyHashable : Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            if let schedule = userInfo["schedule"] as? Schedule {
                self?.routeScheduleView(schedule: schedule)
            } else if let scheduleId = userInfo["scheduleId"] as? Int {
                FullScreenSpinner().show()
                self?.api.getSchedule(scheduleId: scheduleId) { result in
                    FullScreenSpinner().hide()
                    
                    switch result {
                    case .success(let schedule):
                        self?.routeScheduleView(schedule: schedule)
                    case .failure(let error):
                        if error.responseCode == nil {
                            showNetworkErrorDialog()
                        } else {
                            error.showErrorDialog()
                            print("Error occured \(error)")
                        }
                    }
                }
            }
        })
    }
    
    func routeScheduleView(schedule: Schedule) {
        guard let topVC = UIViewController.topViewController else { return }
        
        if schedule.amIHost() {
            let vc = StoryboardManager.loadViewController(storyboard: "HostSchedule",
                                                          viewControllerId: "RequestOverviewViewController") as! RequestOverviewViewController
            vc.schedule = schedule
            topVC.navigationController?.pushViewController(vc, animated: true)
        } else if schedule.amIBooker() {
            let vc = StoryboardManager.loadViewController(storyboard: "Booking",
                                                          viewControllerId: "BookStatusViewController") as! BookStatusViewController
            vc.schedule = schedule
            topVC.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = StoryboardManager.loadViewController(storyboard: "Booking",
                                                          viewControllerId: "TopicDetailViewController") as! TopicDetailViewController
            vc.schedule = schedule
            topVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showWallet() {
        guard let topVC = UIViewController.topViewController else { return }
        
        let vc = StoryboardManager.loadViewController(storyboard: "Wallet",
                                                      viewControllerId: "WalletViewController") as! WalletViewController
        topVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            handleRefreshForTabBar()
        }
    }
    
    func handleRefreshForTabBar() {
        DispatchQueue.main.async {
            guard let themeData = ThemeManager.shared.themeData else { return }
            
            self.tabBar.barStyle = ThemeManager.shared.barStyle
            
            if #available(iOS 15.0, *) {
                let tabAppearance = UITabBarAppearance()
                tabAppearance.configureWithOpaqueBackground()
                tabAppearance.backgroundColor = themeData.defaultBackground.hexColor
                tabAppearance.selectionIndicatorTintColor = themeData.defaultBackground.hexColor
                ThemeManager.shared.updateTabBarItemAppearance(appearance: tabAppearance.compactInlineLayoutAppearance)
                ThemeManager.shared.updateTabBarItemAppearance(appearance: tabAppearance.inlineLayoutAppearance)
                ThemeManager.shared.updateTabBarItemAppearance(appearance: tabAppearance.stackedLayoutAppearance)
                self.tabBar.standardAppearance = tabAppearance
                self.tabBar.scrollEdgeAppearance = tabAppearance
            } else {
                self.tabBar.tintColor = themeData.tabBarTheme.selectedColor.hexColor
                self.tabBar.barTintColor = themeData.defaultBackground.hexColor
                self.tabBar.unselectedItemTintColor = themeData.tabBarTheme.unSelectedColor.hexColor
                self.tabBar.backgroundColor = themeData.defaultBackground.hexColor
            }
        }
    }
}
