//
//  CommonUtils.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import Foundation
import UIKit

let MinimalRedeem = 500

enum LoginMode {
    case phone
    case email
}

enum FollowStatus: Int {
    case notFollowing
    case following
    
    func icon() -> UIImage {
        switch self {
        case .notFollowing:
            return UIImage(systemName: "plus")!
        case .following:
            return UIImage(systemName: "checkmark")!
        }
    }
}

enum Duration: Int {
    case oneHour = 1
    case twoHour = 2
}

enum Association {
    case following
    case followers
}

enum TopicSortTypes: Int {
    case popularity
    case rating
    case price
    case count
    
    func title() -> String {
        switch self {
        case .popularity:
            return "Popularity"
        case .rating:
            return "Rating"
        case .price:
            return "Price"
        default:
            fatalError()
        }
    }
}

typealias Action = () -> Void

class Notifications {
    static let LoginFinished: Notification.Name = Notification.Name("LoginFinished")
    static let RefreshChat: Notification.Name = Notification.Name("RefreshChat")
    static let SwitchToChat: Notification.Name = Notification.Name("SwitchToChat")
    static let StartConversation: Notification.Name = Notification.Name("StartConversation")
    static let UpdateChatBadge: Notification.Name = Notification.Name("UpdateChatBadge")
    static let UpdateHostCalenderBadge: Notification.Name = Notification.Name("UpdateHostCalenderBadge")
    static let SwitchToSchedule: Notification.Name = Notification.Name("SwitchToSchedule")
    static let PresentTopic: Notification.Name = Notification.Name("PresentTopic")
    static let HomeViewFilterPressed: Notification.Name = Notification.Name("HomeViewFilterPressed")
    static let SwitchToCalendar: Notification.Name = Notification.Name("SwitchToCalendar")
    static let OpenProfile: Notification.Name = Notification.Name("OpenProfile")
    static let DidEnterBackground: Notification.Name = Notification.Name("DidEnterBackground")
    static let WillEnterForeground: Notification.Name = Notification.Name("WillEnterForeground")
    static let EndedCall: Notification.Name = Notification.Name("EndedCall")
    static let SwitchToWallet: Notification.Name = Notification.Name("SwitchToWallet")
}

func showErrorDialog(error: String) {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func showNetworkErrorDialog() {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: "Network error, please check Internet connection.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func fileSize(forURL url: Any) -> Double {
    var fileURL: URL?
    var fileSize: Double = 0.0
    if (url is URL) || (url is String) {
        if (url is URL) {
            fileURL = url as? URL
        }
        else {
            fileURL = URL(fileURLWithPath: url as! String)
        }
        var fileSizeValue = 0.0
        try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
    }
    return fileSize
}

func fileSize(forData data: Data) -> Double {
    let fileSize = Double(data.count / 1048576)
    return fileSize
}

func openURLInBrowser(url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}
