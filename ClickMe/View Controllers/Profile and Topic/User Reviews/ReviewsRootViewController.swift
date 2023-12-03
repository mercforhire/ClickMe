//
//  ReviewsRootViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-30.
//

import UIKit
import XLPagerTabStrip

class ReviewsRootViewController: BaseButtonBarPagerTabStripViewController {
    enum Tabs: Int {
        case Host
        case Guest
    }
    
    var userId: Int!
    var userFullName: String?
    
    override func setupTheme() {
        super.setupTheme()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "\(userFullName ?? "")'s Reviews"
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1: UserReviewsTableViewController! = StoryboardManager.loadViewController(storyboard: "OthersProfile", viewControllerId: "UserReviewsTableViewController")
        child1.vcTitle = "As Guest"
        child1.type = .asHost
        child1.userId = userId
        
        let child2: UserReviewsTableViewController! = StoryboardManager.loadViewController(storyboard: "OthersProfile", viewControllerId: "UserReviewsTableViewController")
        child2.vcTitle = "As Host"
        child2.type = .asGuest
        child2.userId = userId
        return [child1, child2]
    }
}
