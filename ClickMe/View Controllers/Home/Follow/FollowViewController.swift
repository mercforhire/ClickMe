//
//  FollowViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class FollowViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let itemInfo = IndicatorInfo(title: "Following")
    private let cellIdentifier = "TopicCell"
   
    private var schedules: [Schedule]? {
        didSet {
            tableView.reloadData()
            noResultsViewContainer.isHidden = !(schedules?.isEmpty ?? true)
        }
    }
    private var filter: TopicFilterCriteria = TopicFilterCriteria() {
        didSet {
            fetchSchedules()
        }
    }
    private var selected: Schedule?
    
    override func setup() {
        super.setup()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchSchedules(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        errorView.configureUI(style: .noFollowing)
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
        fetchSchedules()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notifications.HomeViewFilterPressed, object: nil)
    }
    
    private func fetchSchedules(complete: ((Bool) -> Void)? = nil) {
        guard let user = userManager.user else { return }
        
        schedules == nil ? FullScreenSpinner().show() : nil
        api.getFollowedSchedules(params: filter.exploreEndpointParams(user: user)) { [weak self]  result in
            guard let self = self else { return }
            
            self.schedules == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.schedules = response.content
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
        let vc = TopicFilterViewController.create(filter: filter, delegate: self)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTopic" {
            let viewController = segue.destination as! TopicDetailViewController
            viewController.schedule = selected
        }
    }
}

extension FollowViewController: TopicFilterViewControllerDelegate {
    func topicFilterPicked(filter: TopicFilterCriteria) {
        self.filter = filter
    }
}

extension FollowViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension FollowViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TopicCell, let schedule = schedules?[indexPath.row] else {
            return TopicCell()
        }
        
        cell.config(data: schedule, isSaved: schedule.isSaved)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = schedules?[indexPath.row]
        performSegue(withIdentifier: "goToTopic", sender: self)
    }
}
