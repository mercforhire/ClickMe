//
//  BlockedUsersViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-09-13.
//

import UIKit

class BlockedUsersViewController: BaseViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var users: [ListUser]?
    private var displaying: [ListUser] = [] {
        didSet {
            tableView.reloadData()
            noResultsViewContainer.isHidden = !displaying.isEmpty
        }
    }
    private var delayTimer = DelayedSearchTimer()
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delayTimer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        fetchBlockUsers()
    }
    
    @objc private func unblockButtonPressed(sender: UIButton) {
        guard let blockUsers = userManager.user?.blockedUsers, let clickedUser = users?[sender.tag] else { return }
        
        if blockUsers.contains(clickedUser.identifier) {
            userManager.unblockUser(userId: clickedUser.identifier) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
                }
            }
        } else {
            userManager.blockUser(userId: clickedUser.identifier) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    private func fetchBlockUsers() {
        users == nil ? FullScreenSpinner().show() : nil
        api.getBlockUsers() { [weak self] result in
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

extension BlockedUsersViewController: DelayedSearchTimerDelegate {
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

extension BlockedUsersViewController: UISearchBarDelegate {
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

extension BlockedUsersViewController: UITableViewDataSource, UITableViewDelegate {
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
        cell.config(data: user, blocked: userManager.user?.blockedUsers?.contains(user.identifier) ?? false)
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(unblockButtonPressed(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
