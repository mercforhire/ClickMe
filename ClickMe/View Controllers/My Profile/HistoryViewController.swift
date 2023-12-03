//
//  HistoryViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit

class HistoryViewController: BaseViewController {
    var user: ListUser?
    var host: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    var sections: [String]?
    var schedule: [String: [Schedule]]?
    var selected: Schedule?
    
    override func setup() {
        super.setup()
        
        if let user = user {
            title = "Bookings with \(user.shortName)"
        } else {
            title = host ? "Hosting History" : "Bookings History"
        }
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
        
        fetchHistory()
    }
    
    private func fetchHistory() {
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        var allSchedules: [Schedule]?
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            if self.host {
                self.api.getHostedSchedules { result in
                    switch result {
                    case .success(let response):
                        allSchedules = response
                        isSuccess = true
                    case .failure(let error):
                        DispatchQueue.main.async {
                            if error.responseCode == nil {
                                showNetworkErrorDialog()
                            } else {
                                error.showErrorDialog()
                                print("Error occured \(error)")
                            }
                            isSuccess = false
                        }
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            } else {
                self.api.getHistorySchedules(userId: self.user?.identifier) { result in
                    switch result {
                    case .success(let response):
                        allSchedules = response
                        isSuccess = true
                    case .failure(let error):
                        DispatchQueue.main.async {
                            if error.responseCode == nil {
                                showNetworkErrorDialog()
                            } else {
                                error.showErrorDialog()
                                print("Error occured \(error)")
                            }
                            isSuccess = false
                        }
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.sections = []
            self.schedule = [:]
            for schedule in allSchedules ?? [] {
                guard let key = DateUtil.convert(input: schedule.startTime, outputFormat: .format11) else { continue }
                
                if !self.sections!.contains(key) {
                    self.sections!.append(key)
                }
                
                if self.schedule![key] == nil {
                    self.schedule![key] = []
                }
                
                self.schedule![key]?.append(schedule)
            }
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                self.tableView.reloadData()
                self.noResultsViewContainer.isHidden = !self.schedule!.isEmpty
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBooking", let vc = segue.destination as? BookStatusViewController {
            vc.schedule = selected
        } else if segue.identifier == "goToRequest", let vc = segue.destination as? RequestOverviewViewController {
            vc.schedule = selected
        }
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 22.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections?[section] ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let schedule = schedule, let sections = sections else { return 0 }
        
        return schedule[sections[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell,
              let schedule = schedule,
              let sections = sections,
              let scheduleForToday = schedule[sections[indexPath.section]] else {
            return ScheduleCell()
        }
        cell.config(data: scheduleForToday[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let schedule = schedule, let sections = sections else { return }
        
        let scheduleForToday = schedule[sections[indexPath.section]]
        selected = scheduleForToday?[indexPath.row]
        
        if host {
            performSegue(withIdentifier: "goToRequest", sender: self)
        } else {
            performSegue(withIdentifier: "goToBooking", sender: self)
        }
    }
}
