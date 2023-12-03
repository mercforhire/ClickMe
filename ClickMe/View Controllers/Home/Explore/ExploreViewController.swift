//
//  ExploreViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class ExploreViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var itemInfo = IndicatorInfo(title: "Explore")
    private let cellIdentifier = "PersonCell"
   
    private var users: [ListUser]? {
        didSet {
            tableView.reloadData()
            noResultsViewContainer.isHidden = !(users?.isEmpty ?? true)
        }
    }
    private var filter: PeopleFilterCriteria = PeopleFilterCriteria() {
        didSet {
            fetchUsers()
        }
    }
    private var selectedUser: ListUser?
    
    override func setup() {
        super.setup()
        
        tableView.register(UINib(nibName: "PersonCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchUsers(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showFilterScreen),
                                               name: Notifications.HomeViewFilterPressed,
                                               object: nil)
        
        fetchUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notifications.HomeViewFilterPressed, object: nil)
    }
    
    private func fetchUsers(complete: ((Bool) -> Void)? = nil) {
        guard let user = userManager.user else { return }
        
        users == nil ? FullScreenSpinner().show() : nil
        api.exploreUsers(params: filter.exploreEndpointParams(user: user)) { [weak self]  result in
            guard let self = self else { return }
            
            self.users == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.users = response.content
                complete?(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                complete?(false)
            }
        }
    }
    
    @objc private func showFilterScreen() {
        let vc = PeopleFilterViewController.create(filter: filter, delegate: self)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile", let userId = selectedUser?.identifier {
            let viewController = segue.destination as! ProfileDetailsViewController
            viewController.userId = userId
        }
    }
}

extension ExploreViewController: PeopleFilterViewControllerDelegate {
    func peopleFilterPicked(filter: PeopleFilterCriteria) {
        self.filter = filter
    }
}

extension ExploreViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PersonCell, let user = users?[indexPath.row] else {
            return PersonCell()
        }
        cell.config(data: user, favorited: userManager.user?.likes?.contains(user.identifier) ?? false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users?[indexPath.row]
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
}
