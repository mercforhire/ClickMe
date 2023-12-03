//
//  GuestScheduleViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-24.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class GuestScheduleViewController: BaseViewController {
    static let ViewTitle = "My Schedule"
    
    @IBOutlet weak var tableView: UITableView!
    
    private var itemInfo = IndicatorInfo(title: GuestScheduleViewController.ViewTitle)
    
    var sections: [String]?
    var schedule: [String: [Schedule]]?
    var selected: Schedule?
    
    var currentDate: Date = Date().startOfDay() {
        didSet {
            fetchSchedules()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func setup() {
        super.setup()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchSchedules(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        errorView.configureUI(style: .noSchedules)
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
        
        fetchSchedules()
    }
    
    private func fetchSchedules(complete: ((Bool) -> Void)? = nil) {
        sections == nil ? FullScreenSpinner().show() : nil
        
        var isSuccess: Bool = true
        var allSchedules: [Schedule]?
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.getMyBookedSchedules { result in
                switch result {
                case .success(let response):
                    allSchedules = response
                    isSuccess = true
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    self.sections == nil ? FullScreenSpinner().show() : nil
                    complete?(false)
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
                complete?(true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBooking", let vc = segue.destination as? BookStatusViewController {
            vc.schedule = selected
        }
    }
}

extension GuestScheduleViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension GuestScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 22.0)
        header.textLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
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
        performSegue(withIdentifier: "goToBooking", sender: self)
    }
}
