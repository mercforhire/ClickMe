//
//  FollowersListViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-27.
//

import UIKit
import XLPagerTabStrip

class FollowersListViewController: BaseViewController {
    var vcTitle: String!
    var user: PublicUser!
    var mode: Association = .followers
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var users: [ListUser]?
    private var displaying: [ListUser] = [] {
        didSet {
            tableView.reloadData()
            noResultsViewContainer.isHidden = !displaying.isEmpty
        }
    }
    private var selected: ListUser?
    private var delayTimer = DelayedSearchTimer()
    
    var itemInfo: IndicatorInfo {
        return IndicatorInfo(title: vcTitle)
    }
    
    static func createViewController(title: String) -> FollowersListViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Followers", viewControllerId: "FollowersListViewController") as! FollowersListViewController
        vc.vcTitle = title
        return vc
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delayTimer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch mode {
        case .followers:
            fetchFollowers()
        case .following:
            fetchFollowedUsers()
        }
    }
    
    @objc private func followButtonPressed(sender: UIButton) {
        guard userManager.user?.identifier == user.identifier, let clickedUser = users?[sender.tag] else { return }
        
        if let followingList = user.following, followingList.contains(clickedUser.identifier) {
            userManager.unfollowUser(userId: user.identifier) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
                }
            }
        } else {
            userManager.followUser(userId: clickedUser.identifier) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile", let vc = segue.destination as? ProfileDetailsViewController {
            vc.userId = selected?.identifier
        }
    }
    
    private func fetchFollowers() {
        users == nil ? FullScreenSpinner().show() : nil
        api.getFollowers(userId: user.identifier) { [weak self] result in
            guard let self = self else { return }
            
            self.users == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.users = response
                self.displaying = self.users ?? []
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
    
    private func fetchFollowedUsers() {
        users == nil ? FullScreenSpinner().show() : nil
        api.getFollowedUsers(userId: user.identifier) { [weak self] result in
            guard let self = self else { return }
            
            self.users == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.users = response
                self.displaying = self.users ?? []
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
}

extension FollowersListViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let searchText: String = text.trim()
        
        if searchText.count < 3 {
            displaying = users ?? []
        } else {
            displaying = (users ?? []).filter({ each in
                return each.fullName.contains(string: searchText, caseInsensitive: true)
            })
        }
    }
}

extension FollowersListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delayTimer.textDidGetEntered(text: searchText)
    }
}

extension FollowersListViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension FollowersListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displaying.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as? FollowCell else {
            return FollowCell()
        }
        
        let user = displaying[indexPath.row]
        cell.config(data: user, following: userManager.user?.following?.contains(user.identifier) ?? false)
        
        if userManager.user?.identifier == self.user.identifier {
            cell.followButton.tag = indexPath.row
            cell.followButton.addTarget(self, action: #selector(followButtonPressed(sender:)), for: .touchUpInside)
        } else {
            cell.followButton.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = displaying[indexPath.row]
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
}
