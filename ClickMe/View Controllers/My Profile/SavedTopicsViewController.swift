//
//  SavedScheduleViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-22.
//

import UIKit

class SavedTopicsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var schedules: [Schedule]? {
        didSet {
            tableView.reloadData()
            noResultsViewContainer.isHidden = !(schedules?.isEmpty ?? true)
        }
    }
    private var selected: Schedule?
    
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
        fetchSchedules()
    }
    
    private func fetchSchedules() {
        schedules == nil ? FullScreenSpinner().show() : nil
        api.getFavoriteSchedules() { [weak self]  result in
            guard let self = self else { return }
            
            self.schedules == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.schedules = response
                self.tableView.reloadData()
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTopic", let vc = segue.destination as? TopicDetailViewController {
            vc.schedule = selected
        }
    }
}

extension SavedTopicsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedTopicCell", for: indexPath) as? ScheduleCell, let schedule = schedules?[indexPath.row] else {
            return ScheduleCell()
        }
        
        cell.config(data: schedule)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = schedules?[indexPath.row]
        performSegue(withIdentifier: "goToTopic", sender: self)
    }
}
