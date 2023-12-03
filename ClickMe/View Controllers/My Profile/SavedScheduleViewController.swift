//
//  SavedScheduleViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-22.
//

import UIKit

struct SavedScheduleModel {
    var date: Date
    var duration: Int
    var topic: String
}

class SavedTopicsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var sections: [String] = []
    var schedule: [String: [SavedScheduleModel]] = [:]
    
    var currentDate: Date = Date().startOfDay() {
        didSet {
            generateRandomEvents()
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        generateRandomEvents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    func generateRandomEvents() {
        var topics: [SavedScheduleModel] = []
        for hour in 0...100 {
            if Bool.random() {
                topics.append(SavedScheduleModel(date: currentDate.getPastOrFutureDate(hour: hour), duration: Int.random(in: 1...2), topic: Lorem.sentence))
            }
        }
        
        sections.removeAll()
        schedule.removeAll()
        
        for topic in topics {
            guard let key = DateUtil.convert(input: topic.date, outputFormat: .format11) else { continue }
            
            if !sections.contains(key) {
                sections.append(key)
            }
            
            if schedule[key] == nil {
                schedule[key] = []
            }
            
            schedule[key]?.append(topic)
        }
    }
}

extension SavedTopicsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule[sections[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedScheduleCell", for: indexPath) as? SavedScheduleCell,
              let scheduleForToday = schedule[sections[indexPath.section]] else {
            return SavedScheduleCell()
        }
        
        cell.config(data: scheduleForToday[indexPath.row])
        return cell
    }
}
