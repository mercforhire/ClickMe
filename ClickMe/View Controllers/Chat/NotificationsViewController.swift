//
//  NotificationsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import UIKit
import SwipeCellKit
import CRRefresh

class NotificationsViewController: BaseViewController {
    @IBOutlet weak var tableview: UITableView!
    
    private var notifications: [NotificationMessage] = []
    
    override func setup() {
        super.setup()
        
        tableview.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                /// Stop refresh when your job finished, it will reset refresh footer if completion is true
                self?.organizeData()
                self?.tableview.cr.endHeaderRefresh()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        organizeData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        DataManager.shared.clearUnreadNotifications()
    }
    
    func organizeData() {
//        notifications = DataManager.shared.getNotifications()
        tableview.reloadData()
    }
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else {
            return NotificationTableViewCell()
        }
        
        cell.config(data: notifications[indexPath.row])
        return cell
    }
}
