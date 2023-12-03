//
//  ScheduleViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-19.
//

import UIKit
import FSCalendar
import CRRefresh

class ScheduleViewController: BaseViewController {
    var host: PublicUser!
    
    @IBOutlet weak var calendar: ThemeCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    private var allSchedules: [Schedule]?
    private var schedulesInSelectedDay: [Schedule] = []
    private var selected: Schedule?
    private var currentDate: Date! {
        didSet {
            getSchedulesForSelectedDay()
            
            if !schedulesInSelectedDay.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                    self?.tableView.scrollToTop(animated: true)
                })
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        title = "\(host.fullName)'s schedule"
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self?.fetchSchedules(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        
        calendar.appearance.headerTitleFont = UIFont(name: "SFUIDisplay-Regular", size: 17.0)
        calendar.appearance.weekdayFont = UIFont(name: "SFUIDisplay-Regular", size: 17.0)
        calendar.appearance.titleFont = UIFont(name: "SFUIDisplay-Regular", size: 17.0)
        calendar.configureAppearance()
        calendar.setupUI()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentDate = Date().startOfDay()
        calendar.select(currentDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = themeManager.themeData!.indigo.hexColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.themeData!.whiteBackground.hexColor]
        
        fetchSchedules()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.barTintColor = themeManager.themeData!.navBarTheme.backgroundColor.hexColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.themeData!.navBarTheme.textColor.hexColor]
    }
    
    private func fetchSchedules(complete: ((Bool) -> Void)? = nil) {
        allSchedules == nil ? FullScreenSpinner().show() : nil
        api.getUserSchedules(userId: host.identifier) { [weak self]  result in
            guard let self = self else { return }
            
            self.allSchedules == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.allSchedules = response
                self.getSchedulesForSelectedDay()
                self.calendar.reloadData()
                complete?(true)
            case .failure(let error):
                if let _ = error.responseCode {
                    error.showErrorDialog()
                } else {
                    showNetworkErrorDialog()
                }
                
                complete?(false)
            }
        }
    }
    
    private func getSchedulesForSelectedDay() {
        schedulesInSelectedDay = allSchedules?.filter { schedule in
            return currentDate.isInSameDay(date: schedule.startTime)
        } ?? []
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TopicDetailViewController {
            vc.schedule = selected
        }
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 22.0)
        header.textLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateUtil.convert(input: currentDate, outputFormat: .format9)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedulesInSelectedDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? TopicCell else {
            return TopicCell()
        }
        let schedule = schedulesInSelectedDay[indexPath.row]
        cell.config(data: schedule, isSaved: schedule.isSaved)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = schedulesInSelectedDay[indexPath.row]
        performSegue(withIdentifier: "goToTopic", sender: self)
    }
}

extension ScheduleViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date.startOfDay()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for schedule in allSchedules ?? [] {
            if date.isInSameDay(date: schedule.startTime) {
                return 1
            }
        }
        
        return 0
    }
}
