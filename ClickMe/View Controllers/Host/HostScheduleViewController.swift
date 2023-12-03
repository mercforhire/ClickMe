//
//  HostScheduleViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit
import FSCalendar
import CRRefresh

class HostScheduleViewController: BaseViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var calendar: ThemeCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var selected: Schedule?
    private var calendarDefaultHeight: CGFloat!
    
    var calendarExpanded = true {
        didSet {
            if calendarExpanded {
                self.calendarHeight.constant = self.calendarDefaultHeight
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.arrowButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                })
            } else {
                self.calendarHeight.constant = 0.0
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.arrowButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                })
            }
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                self?.tableView.scrollToTop(animated: true)
            })
        }
    }
    
    var allSchedules: [Schedule]?
    var schedulesInSelectedDay: [Schedule] = []
    var currentDate: Date! {
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
        
        arrowButton.setImage(UIImage(systemName: "chevron.up")  , for: .normal)
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
        
        headerView.backgroundColor = themeManager.themeData!.indigo.hexColor
        headerLabel.font = themeManager.themeData!.navBarTheme.font.toFont()!
        headerLabel.textColor = themeManager.themeData!.navBarTheme.textColor.hexColor
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
        
        if calendarDefaultHeight == nil {
            calendarDefaultHeight = calendar.frame.height
        }
        
        navigationController?.navigationBar.isHidden = true
        fetchSchedules()
        showTutorialIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func expandPress(_ sender: Any) {
        calendarExpanded = !calendarExpanded
    }
    
    private func fetchSchedules(complete: ((Bool) -> Void)? = nil) {
        allSchedules == nil ? FullScreenSpinner().show() : nil
        
        userManager.fetchHostSchedule { [weak self] schedules, error in
            guard let self = self else { return }
            
            self.allSchedules == nil ? FullScreenSpinner().hide() : nil
            
            if let error = error {
                if let _ = error.responseCode {
                    error.showErrorDialog()
                } else {
                    showNetworkErrorDialog()
                }                
                complete?(false)
            } else {
                self.allSchedules = schedules
                self.getSchedulesForSelectedDay()
                self.calendar.reloadData()
                complete?(true)
            }
        }
    }
    
    private func getSchedulesForSelectedDay() {
        let schedulesInSelectedDay = allSchedules?.filter { schedule in
            return currentDate.isInSameDay(date: schedule.startTime)
        } ?? []
        let sorted = schedulesInSelectedDay.sorted { left, right in
            return left.startTime < right.startTime
        }
        self.schedulesInSelectedDay = sorted
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selected = selected else { return }
        
        if let vc = segue.destination as? RequestOverviewViewController {
            vc.schedule = selected
        } else if let vc = segue.destination as? EditTopicViewController {
            vc.mode = .editSchedule(selected)
        } else if let vc = segue.destination as? TopicDetailViewController {
            vc.schedule = selected
        }
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        tutorialManager?.showTutorial()
    }
}

extension HostScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 22.0)
        header.textLabel?.textColor = themeManager.themeData!.textLabel.hexColor
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return calendarExpanded ? 50.0 : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateUtil.convert(input: currentDate, outputFormat: .format11)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if calendarExpanded {
            return schedulesInSelectedDay.count
        } else {
            return allSchedules?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HostScheduleCell", for: indexPath) as? HostScheduleCell,
              let schedule = calendarExpanded ? schedulesInSelectedDay[indexPath.row] : allSchedules?[indexPath.row] else {
            return HostScheduleCell()
        }
        
        cell.config(data: schedule, showDate: !calendarExpanded)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let schedule = calendarExpanded ? schedulesInSelectedDay[indexPath.row] : allSchedules?[indexPath.row] else { return }
        
        selected = schedule
        if schedule.status == .open {
            performSegue(withIdentifier: "goToEdit", sender: self)
        } else if schedule.booker != nil {
            performSegue(withIdentifier: "goToOverview", sender: self)
        } else {
            performSegue(withIdentifier: "goToTopic", sender: self)
        }
    }
}

extension HostScheduleViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
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

extension HostScheduleViewController: TutorialSupport {
    func stepOpened(stepCount: Int) {
        
    }
    
    func screenName() -> TutorialName {
        return TutorialName.hostCalendar
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        guard let tabBarControllerFrame = tabBarController?.tabBar.globalFrame,
              var targetFrame = tabBarController?.tabBar.getFrameForTabAt(index: 1) else { return [] }
        
        targetFrame.origin.y = targetFrame.origin.y + tabBarControllerFrame.origin.y
        
        let step1 = TutorialStep(screenName: "\(TutorialName.hostCalendar.rawValue) + 1",
                                body: "See the ClickMe sessions\nyou are hosting in one place.",
                                pointingDirection: .down,
                                pointPosition: .edge,
                                targetFrame: targetFrame,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step1)
        
        return tutorialSteps
    }
}
