//
//  ManageFollowerRootViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-27.
//

import UIKit
import XLPagerTabStrip

class ManageFollowerRootViewController: BaseButtonBarPagerTabStripViewController {
    var user: PublicUser!
    var defaultAssociation: Association = .following
    
    override func setup() {
        super.setup()
        
        title = user.fullName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
        switch defaultAssociation {
        case .following:
            moveToViewController(at: 0, animated: false)
        case .followers:
            moveToViewController(at: 1, animated: false)
        }
    }

    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1 = FollowersListViewController.createViewController(title: "Following")
        child1.mode = .following
        child1.user = user
        let child2 = FollowersListViewController.createViewController(title: "Followers")
        child2.mode = .followers
        child2.user = user
        return [child1, child2]
    }
}
