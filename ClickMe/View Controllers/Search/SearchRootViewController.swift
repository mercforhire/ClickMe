//
//  SearchRootViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit
import XLPagerTabStrip

class SearchRootViewController: BaseButtonBarPagerTabStripViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    private var delayTimer = DelayedSearchTimer()
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1: SearchPeopleViewController! = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "SearchResultsViewController")
        child1.tabTitle = "Accounts"
        child1.delayTimer = delayTimer
        
        let child2: SearchTopicsViewController! = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "SearchTopicsViewController")
        child2.tabTitle = "ClickMe"
        child2.delayTimer = delayTimer
        return [child1, child2]
    }
}

extension SearchRootViewController: UISearchBarDelegate {
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
