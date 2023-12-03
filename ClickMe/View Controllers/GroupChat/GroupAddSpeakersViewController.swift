//
//  GroupAddSpeakersViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-19.
//

import UIKit

protocol GroupAddSpeakersViewControllerDelegate: class {
    func pickedUsers(users: [ListUser])
}
class GroupAddSpeakersViewController: BaseViewController {
    var maximumSpeakersCount: Int!
    var preSelectedUsers: [ListUser]!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    private var users: [ListUser]? {
        didSet {
            tableview.reloadData()
        }
    }
    private var selected: [Int: ListUser] = [:]
    private var delayTimer = DelayedSearchTimer()
    weak var delegate: GroupAddSpeakersViewControllerDelegate?
    
    override func setup() {
        super.setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for preselectedUser in preSelectedUsers {
            selected[preselectedUser.identifier] = preselectedUser
        }
        delayTimer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delayTimer.timerFired()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.pickedUsers(users: Array(selected.values))
    }
    
    private func fetchExploreUsers() {
        users == nil ? FullScreenSpinner().show() : nil
        api.exploreUsers(params: ExploreUserParams()) { [weak self] result in
            guard let self = self else { return }
            
            self.users == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.users = response.content
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
    
    private func searchUsers(keywords: String) {
        users == nil ? FullScreenSpinner().show() : nil
        api.searchUsers(keyword: keywords) { [weak self] result in
            guard let self = self else { return }
            
            self.users == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.users = response.content
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

extension GroupAddSpeakersViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let text: String = text.trim()
        
        if text.count < 3 {
            fetchExploreUsers()
        } else {
            searchUsers(keywords: text)
        }
    }
}

extension GroupAddSpeakersViewController: UISearchBarDelegate {
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

extension GroupAddSpeakersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return selected.isEmpty ? 0.0 : 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selected.count
        } else {
            return users?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakerSelectionCell", for: indexPath) as? SpeakerSelectionCell else {
            return SpeakerSelectionCell()
        }
        
        if indexPath.section == 0 {
            cell.config(data: Array(selected.values)[indexPath.row], included: true)
        } else if let user = users?[indexPath.row] {
            cell.config(data: user, included: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1, let user = users?[indexPath.row] {
            return selected[user.identifier] != nil ? 0 : UITableView.automaticDimension
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let user = Array(selected.values)[indexPath.row]
            selected[user.identifier] = nil
            tableView.reloadData()
        } else if let user = users?[indexPath.row] {
            if selected[user.identifier] == nil,
               selected.count < maximumSpeakersCount {
                selected[user.identifier] = user
                tableView.reloadData()
            }
        }
    }
}
