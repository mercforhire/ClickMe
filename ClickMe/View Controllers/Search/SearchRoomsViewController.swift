//
//  SearchRoomsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-22.
//

import UIKit

class SearchRoomsViewController: BaseViewController {

    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    private var allRooms: [GroupChatRoom] = []
    private var displayedRooms: [GroupChatRoom] = [] {
        didSet {
            tableview.reloadData()
            noResultsViewContainer.isHidden = !displayedRooms.isEmpty
        }
    }
    private var delayTimer = DelayedSearchTimer()
    
    
    override func setup() {
        super.setup()
        
        errorView.configureUI(style: .noSearchResults)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allRooms = []
        displayedRooms = allRooms
        delayTimer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    private func openRoom(room: GroupChatRoom) {
        let vc = GroupChatViewController.create(room: room)
        present(vc, animated: true, completion: nil)
    }
}

extension SearchRoomsViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let searchText: String = text.trim()
        
        if searchText.count < 3 {
            displayedRooms = allRooms
        } else {
            displayedRooms = allRooms.filter({ each in
                return each.title.contains(string: searchText, caseInsensitive: true)
            })
        }
    }
}

extension SearchRoomsViewController: UISearchBarDelegate {
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

extension SearchRoomsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchRoomCell", for: indexPath) as? SearchRoomCell else {
            return SearchRoomCell()
        }
        let room = displayedRooms[indexPath.row]
        cell.config(room: room)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openRoom(room: displayedRooms[indexPath.row])
    }
}
