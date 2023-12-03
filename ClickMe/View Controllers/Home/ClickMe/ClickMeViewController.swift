//
//  ClickMeViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class ClickMeViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    private var itemInfo = IndicatorInfo(title: "ClickMe")
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
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topDownContentInset: CGFloat = 10
        let leftRightContentInset: CGFloat = 20
        let itemSpace: CGFloat = 5
        let itemsPerRow: CGFloat = 4
        let itemsPerColumn: CGFloat = 2
        
        let flowlayout = UICollectionViewFlowLayout()
        let cellWidth: CGFloat = (collectionView.frame.width - leftRightContentInset * 2 - (itemsPerRow - 1) * itemSpace) / itemsPerRow
        let cellHeight: CGFloat = (collectionView.frame.height - topDownContentInset * 2 - (itemsPerColumn - 1) * itemSpace) / itemsPerColumn
        flowlayout.itemSize = .init(width: cellWidth, height: cellHeight)
        flowlayout.scrollDirection = .horizontal
        flowlayout.sectionInset = .init(top: topDownContentInset, left: leftRightContentInset, bottom: topDownContentInset, right: leftRightContentInset)
        flowlayout.minimumLineSpacing = itemSpace
        flowlayout.minimumInteritemSpacing = itemSpace
        collectionView.setCollectionViewLayout(flowlayout, animated: false)
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
        api.exploreSchedules(params: filter.exploreEndpointParams(user: user)) { [weak self]  result in
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

extension ClickMeViewController: TopicFilterViewControllerDelegate {
    func topicFilterPicked(filter: TopicFilterCriteria) {
        self.filter = filter
    }
}

extension ClickMeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Mood.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! ImageAndLabelNormalCell
        cell.roundCorners(style: .medium)
        cell.config(data: Mood.list()[indexPath.row])
        if filter.mood == Mood.list()[indexPath.row] {
            cell.highlight()
        } else {
            cell.unhighlight()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filter.mood == Mood.list()[indexPath.row] {
            filter.mood = nil
        } else {
            filter.mood = Mood.list()[indexPath.row]
        }
        collectionView.reloadData()
    }
}

extension ClickMeViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension ClickMeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TopicCell,
              let schedule = schedules?[indexPath.row] else {
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

