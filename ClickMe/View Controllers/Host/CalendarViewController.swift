//
//  HostScheduleViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit
import FSCalendar

class HostScheduleViewController: BaseViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var pendingAllButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let calendarDefaultHeight: CGFloat = 200.0
    
    var calendarExpanded = true {
        didSet {
            if calendarExpanded {
                self.calendarHeight.constant = self.calendarDefaultHeight
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.arrowButton.setBackgroundImage(UIImage(systemName: "arrow.up.square.fill")!, for: .normal)
                })
            } else {
                self.calendarHeight.constant = 0.0
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.arrowButton.setBackgroundImage(UIImage(systemName: "arrow.down.square.fill")!, for: .normal)
                })
            }
        }
    }
    
    var pendingOnly = false {
        didSet {
            if pendingOnly {
                displayedSchedules = allSchedules.filter { model -> Bool in
                    return model.status == .pending
                }
                pendingAllButton.setTitle("See all", for: .normal)
            } else {
                displayedSchedules = allSchedules
                pendingAllButton.setTitle("See pending", for: .normal)
            }
            tableView.reloadData()
        }
    }
    
    var allSchedules: [HostSchedule] = []
    var displayedSchedules: [HostSchedule] = []
    
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
        navigationController?.navigationBar.isHidden = true
        calendar.select(currentDate)
        generateRandomEvents()
    }
    
    @IBAction func expandPress(_ sender: Any) {
        calendarExpanded = !calendarExpanded
    }
    
    @IBAction func pendingAllPress(_ sender: UIButton) {
        pendingOnly = !pendingOnly
    }
    
    func generateRandomEvents() {
        allSchedules.removeAll()
        displayedSchedules.removeAll()
        for hour in 0...23 {
            if Bool.random() {
                let data = HostSchedule.random(startDate: currentDate.getPastOrFutureDate(hour: hour), host: currentUser)
                allSchedules.append(data)
            }
        }
        pendingOnly = false
    }
}

extension HostScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateUtil.convert(input: currentDate, outputFormat: .format12)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedSchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HostScheduleCell", for: indexPath) as? HostScheduleCell else {
            return HostScheduleCell()
        }
        
        cell.config(data: displayedSchedules[indexPath.row])
        return cell
    }
}

extension HostScheduleViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date.startOfDay()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return date >= Date().startOfDay()
    }
}
