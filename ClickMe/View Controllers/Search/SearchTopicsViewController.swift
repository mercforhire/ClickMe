//
//  SearchTopicsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-04.
//

import UIKit
import XLPagerTabStrip

class SearchTopicsViewController: BaseViewController {
    var delayTimer: DelayedSearchTimer!
    
    var tabTitle: String!
    var itemInfo: IndicatorInfo {
        return IndicatorInfo(title: tabTitle)
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var schedules: [Schedule]? {
        didSet {
            tableView.reloadData()
            noResultsViewContainer.isHidden = !(schedules?.isEmpty ?? true)
        }
    }
    var selected: Schedule?
    
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
        if segue.identifier == "goToTopic", let vc = segue.destination as? TopicDetailViewController {
            vc.schedule = selected
        }
    }
    
    private func fetchExploreSchedules() {
        schedules == nil ? FullScreenSpinner().show() : nil
        api.exploreSchedules(params: ExploreSchedulesParams()) { [weak self] result in
            guard let self = self else { return }
            
            self.schedules == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.schedules = response.content
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
    
    private func searchSchedules(keywords: String) {
        schedules == nil ? FullScreenSpinner().show() : nil
        api.searchSchedules(keyword: keywords) { [weak self] result in
            guard let self = self else { return }
            
            self.schedules == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.schedules = response
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

extension SearchTopicsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension SearchTopicsViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let text: String = text.trim()
        
        if text.count < 3 {
            fetchExploreSchedules()
        } else {
            searchSchedules(keywords: text.trim())
        }
    }
}

extension SearchTopicsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTopicCell", for: indexPath) as? SearchTopicCell, let schedule = schedules?[indexPath.row] else {
            return SearchTopicCell()
        }
        cell.config(data: schedule)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = schedules?[indexPath.row]
        performSegue(withIdentifier: "goToTopic", sender: self)
    }
}
