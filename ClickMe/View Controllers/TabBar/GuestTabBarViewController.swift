//
//  GuestTabBarViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-01.
//

import UIKit

class GuestTabBarViewController: BaseTabBarViewController {
    enum Tabs: Int {
        case home
//        case group
        case chat
        case profile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.viewControllers = [self]
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToChat), name: Notifications.SwitchToChat, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateChatBadgeCount), name: Notifications.UpdateChatBadge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openProfile), name: Notifications.OpenProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToSchedule), name: Notifications.SwitchToSchedule, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToWallet), name: Notifications.SwitchToWallet, object: nil)
        
        appSettings.setLastUsedMode(mode: "guest")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userManager.fetchConversations { _, _ in
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func updateChatBadgeCount(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let badgeCount = userInfo["badgeCount"] as? Int, badgeCount > 0 {
            tabBar.items?[Tabs.chat.rawValue].badgeValue = "\(badgeCount)"
        } else {
            tabBar.items?[Tabs.chat.rawValue].badgeValue = nil
        }
    }
    
    @objc func switchToChat(_ notification: Notification) {
        if let modalVC = UIViewController.topViewController {
            modalVC.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                if let _ = UIViewController.topViewController as? GroupChatViewController {
                    showErrorDialog(error: "Can't not switch to Chat while inside the Group Chat window")
                    return
                }
                
                self.selectedIndex = Tabs.chat.rawValue
                if let navVC = self.viewControllers?[Tabs.chat.rawValue] as? UINavigationController, let topMostVC = navVC.viewControllers.last {
                    topMostVC.navigationController?.popToRootViewController(animated: true)
                }
                if let userInfo = notification.userInfo {
                    self.sendStartConversationNotification(userInfo: userInfo)
                }
            }
        }
    }
    
    @objc func switchToSchedule(_ notification: Notification) {
        if let modalVC = UIViewController.topViewController {
            modalVC.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                if let _ = UIViewController.topViewController as? GroupChatViewController {
                    showErrorDialog(error: "Can't not switch to Schedule while inside the Group Chat window")
                    return
                }
                
                self.selectedIndex = Tabs.home.rawValue
                if let userInfo = notification.userInfo {
                    self.handlePresentScheduleView(userInfo: userInfo)
                }
            }
        }
    }
    
    @objc func switchToWallet() {
        if let modalVC = UIViewController.topViewController {
            modalVC.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                if let _ = UIViewController.topViewController as? GroupChatViewController {
                    showErrorDialog(error: "Can't not switch to Wallet while inside the Group Chat window")
                    return
                }
                
                self.selectedIndex = Tabs.profile.rawValue
                
                self.showWallet()
            }
        }
    }
    
    @objc func openProfile(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let userId = userInfo["userId"] as? Int else { return }
        
        if let topVC = UIViewController.topViewController {
            let vc = StoryboardManager.loadViewController(storyboard: "OthersProfile", viewControllerId: "ProfileDetailsViewController") as! ProfileDetailsViewController
            vc.userId = userId
            topVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func sendStartConversationNotification(userInfo: [AnyHashable : Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            NotificationCenter.default.post(name: Notifications.StartConversation, object: nil, userInfo: userInfo)
        })
    }
}
