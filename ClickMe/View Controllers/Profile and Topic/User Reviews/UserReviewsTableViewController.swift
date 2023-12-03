//
//  UserReviewsTableViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-29.
//

import UIKit
import ExpandableLabel
import XLPagerTabStrip

class UserReviewsTableViewController: BaseTableViewController {
    var vcTitle: String!
    var type: ReviewType!
    var userId: Int!
    
    var reviews: [Review]? {
        didSet {
            states = [Bool](repeating: true, count: reviews?.count ?? 0)
            tableView.reloadData()
        }
    }
    var states: Array<Bool>!
    var itemInfo: IndicatorInfo {
        return IndicatorInfo(title: vcTitle)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchReviews()
    }
    
    private func fetchReviews() {
        reviews == nil ? FullScreenSpinner().show() : nil
        
        api.getAllReviews(userId: userId, reviewType: type) { [weak self] result in
            guard let self = self else { return }
            
            self.reviews == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.reviews = response
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (reviews?.isEmpty ?? true) ? 1 : reviews?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if reviews?.isEmpty ?? true {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoReviewsTableViewCell", for: indexPath) as? NoReviewsTableViewCell else {
                return NoReviewsTableViewCell()
            }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell, let review = reviews?[indexPath.row] else {
            return ReviewCell()
        }
        cell.container.backgroundColor = indexPath.row % 2 == 0 ? themeManager.themeData!.whiteBackground.hexColor : themeManager.themeData!.defaultBackground.hexColor
        cell.config(data: review)
        cell.bodyLabel.tag = indexPath.row
        cell.bodyLabel.delegate = self
        cell.bodyLabel.collapsed = states[indexPath.row]
        return cell
    }
}


extension UserReviewsTableViewController: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        tableView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let indexPath = IndexPath(item: label.tag, section: 0)
        states[indexPath.row] = false
        DispatchQueue.main.async { [weak self] in
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        tableView.endUpdates()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        tableView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let indexPath = IndexPath(item: label.tag, section: 0)
        states[indexPath.row] = true
        DispatchQueue.main.async { [weak self] in
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        tableView.endUpdates()
    }
}

extension UserReviewsTableViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
