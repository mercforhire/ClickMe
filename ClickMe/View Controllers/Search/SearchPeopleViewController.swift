//
//  SearchViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit
import XLPagerTabStrip

class SearchPeopleViewController: BaseViewController {
    var delayTimer: DelayedSearchTimer!
    
    var tabTitle: String!
    var itemInfo: IndicatorInfo {
        return IndicatorInfo(title: tabTitle)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var users: [ListUser]? {
        didSet {
            tableView.reloadData()
            noResultsViewContainer.isHidden = !(users?.isEmpty ?? true)
        }
    }
    private var selected: ListUser?
    
    override func setup() {
        super.setup()
        
        errorView.configureUI(style: .noSearchResults)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delayTimer.delegate = self
        delayTimer.timerFired()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile",
           let vc = segue.destination as? ProfileDetailsViewController {
            vc.userId = selected?.identifier
        }
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

extension SearchPeopleViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension SearchPeopleViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let text: String = text.trim()
        
        if text.count < 3 {
            fetchExploreUsers()
        } else {
            searchUsers(keywords: text.trim())
        }
    }
}

extension SearchPeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPersonCell", for: indexPath) as? SearchPersonCell,
              let user = users?[indexPath.row] else {
            return SearchPersonCell()
        }
        cell.config(data: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = users?[indexPath.row]
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
}
