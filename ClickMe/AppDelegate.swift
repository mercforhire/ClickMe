//
//  AppDelegate.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit
import KeyboardDismisser

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var lastNoti: UNNotificationResponse?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        KeyboardDismisser.shared.attach()
        
        if UITraitCollection.current.userInterfaceStyle == .dark {
            ThemeManager.shared.setDarkTheme()
        } else {
            ThemeManager.shared.setLightTheme()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginFinished), name: Notifications.LoginFinished, object: nil)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        ClickAPI.shared.saveToken(token: token) { result in
            switch result {
            case .success:
                print("saveToken success")
                AppSettingsManager.shared.setDeviceToken(token: token)
            case .failure(let error):
                print("saveToken error: \(error.errorDescription ?? "")")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func handleNoti(inApp: Bool, userInfo: [AnyHashable : Any], completionHandler: ((UNNotificationPresentationOptions) -> Void)? = nil) {
        guard let type = userInfo["type"] as? String else { return }
        
        if type == "saveChatMessage", let userId = userInfo["userId"] as? Int {
            if inApp {
                if (UIViewController.topViewController?.isKind(of: ChatViewController.self) ?? false) ||
                    (UIViewController.topViewController?.isKind(of: ChatConversationsViewController.self) ?? false) &&
                    (UserManager.shared.talkingWith == nil || UserManager.shared.talkingWith?.identifier == userId) {
                    NotificationCenter.default.post(name: Notifications.RefreshChat, object: nil, userInfo: ["userId": userId])
                } else {
                    completionHandler?([.sound, .banner])
                }
            } else {
                NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["userId": userId])
                completionHandler?([.sound, .banner])
            }
        } else if type == "endedCall" {
            NotificationCenter.default.post(name: Notifications.EndedCall, object: nil, userInfo: nil)
            completionHandler?([.sound, .banner])
        } else if type == "tipUser" {
            if !inApp {
                NotificationCenter.default.post(name: Notifications.SwitchToWallet, object: nil, userInfo: nil)
            }
            completionHandler?([.sound, .banner])
        } else if let scheduleId = userInfo["scheduleId"] as? Int {
            if !inApp {
                NotificationCenter.default.post(name: Notifications.SwitchToSchedule, object: nil, userInfo: ["scheduleId": scheduleId])
            }
            completionHandler?([.sound, .banner])
        } else if let userId = userInfo["userId"] as? Int {
            NotificationCenter.default.post(name: Notifications.OpenProfile, object: nil, userInfo: ["userId": userId])
            completionHandler?([.sound, .banner])
        }
    }
    
    @objc private func handleLoginFinished() {
        guard let lastNoti = lastNoti else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.handleNoti(inApp: false, userInfo: lastNoti.notification.request.content.userInfo)
            self.lastNoti = nil
        })
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // show the notification alert (banner), and with sound
        print("userNotificationCenter willPresent:")
        print(notification.request.content.userInfo)
        
        if !UserManager.shared.inCallScreen {
            handleNoti(inApp: true, userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
        }
    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // tell the app that we have finished processing the user’s action / response
        print("userNotificationCenter didReceive:")
        print(response.notification.request.content.userInfo)
        completionHandler()
        
        if UserManager.shared.isLoggedIn() && UserManager.shared.user == nil {
            lastNoti = response
        } else {
            handleNoti(inApp: false, userInfo: response.notification.request.content.userInfo)
        }
    }
}
