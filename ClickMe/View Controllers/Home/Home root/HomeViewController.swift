//
//  HomeViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit
import XLPagerTabStrip
import UserNotifications

class HomeViewController: BaseButtonBarPagerTabStripViewController {
    enum Tabs: Int {
        case Follow
        case Explore
        case ClickMe
        case MySchedule
    }
    
    @IBOutlet var dummyButton: UIBarButtonItem!
    @IBOutlet var filterButton: UIBarButtonItem!
    private var selectedSchedule: Schedule?
    
    override func setupTheme() {
        super.setupTheme()
        
        addNavLogo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerForPushNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        showTutorialIfNeeded()
    }
    
    private func registerForPushNotifications() {
        if AppSettingsManager.shared.getDeviceToken() == nil {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    print("Permission granted: \(granted)")
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
        }
    }
    
    @IBAction func filterPressed(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notifications.HomeViewFilterPressed, object: nil, userInfo: nil)
    }
    
    @objc func handleSwitchToBooking(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let schedule = userInfo["schedule"] as? Schedule {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.goToTopic(schedule: schedule)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TopicDetailViewController {
            vc.schedule = selectedSchedule
        }
    }
    
    private func goToTopic(schedule: Schedule) {
        selectedSchedule = schedule
        performSegue(withIdentifier: "goToTopic", sender: self)
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        tutorialManager?.showTutorial()
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "FollowViewController")
        let child2: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "ExploreViewController")
        let child3: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "ClickMeViewController")
        let child4: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "GuestScheduleViewController")
        return [child1, child2, child3, child4]
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        
        guard progressPercentage == 1.0 else { return }
        
        if toIndex == Tabs.Follow.rawValue || toIndex == Tabs.MySchedule.rawValue {
            self.navigationItem.rightBarButtonItems = [self.dummyButton]
        } else {
            self.navigationItem.rightBarButtonItems = [self.filterButton]
        }
    }
}

extension HomeViewController: TutorialSupport {
    func screenName() -> TutorialName {
        return TutorialName.home
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        let step = TutorialStep(screenName: "\(screenName()) + 1",
                                body: "This is where the people that\nyou are following will show up\nwith their lastest ClickMe sessions",
                                pointingDirection: .up,
                                pointPosition: .edge,
                                targetFrame: buttonBarView.frame,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step)
        
        let step2 = TutorialStep(screenName: "\(screenName()) + 2",
                                body: "Find out who is the hottest in your field\nand follow them for any news",
                                pointingDirection: .up,
                                pointPosition: .edge,
                                targetFrame: buttonBarView.frame,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step2)
        
        let step3 = TutorialStep(screenName: "\(screenName()) + 3",
                                body: "Most popular and recent\nClickMe sessions show up here",
                                pointingDirection: .up,
                                pointPosition: .edge,
                                targetFrame: buttonBarView.frame,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step3)
        
        let step4 = TutorialStep(screenName: "\(screenName()) + 4",
                                body: "See your scheduled ClickMe sessions all at once",
                                pointingDirection: .up,
                                pointPosition: .edge,
                                targetFrame: buttonBarView.frame,
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step4)
        
        return tutorialSteps
    }
    
    func stepOpened(stepCount: Int) {
        moveToViewController(at: stepCount, animated: true)
    }
}
