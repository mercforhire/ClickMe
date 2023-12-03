//
//  ManagementRootViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit

class ManagementRootViewController: BaseViewController {
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var whiteContainer1: UIView!
    @IBOutlet weak var whiteContainer2: UIView!
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var pendingCount: UILabel!
    @IBOutlet weak var todayCount: UILabel!
    @IBOutlet weak var scheduleContainer: UIView!
    @IBOutlet weak var topicContainer: UIView!
    
    override func setup() {
        super.setup()
        
        greetingLabel.text = "Hello, \(userManager.user?.fullName ?? "")"
        whiteContainer1.layer.cornerRadius = 30.0
        whiteContainer2.layer.cornerRadius = 30.0
        scheduleContainer.layer.cornerRadius = 12.0
        topicContainer.layer.cornerRadius = 12.0
        
        addNavLogo()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pendingCount.text = "--"
        todayCount.text = "--"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchSchedules()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            self?.showTutorialIfNeeded()
        })
    }
    
    private func fetchSchedules(complete: ((Bool) -> Void)? = nil) {
        api.getUserSchedules() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let pending = response.filter { subject in
                    return subject.status == .pending
                }.count
                
                let total = response.filter { subject in
                    return subject.startTime.isInToday()
                }.count
                
                self.pendingCount.text = "\(pending)"
                self.todayCount.text = "\(total)"
                
                complete?(true)
            case .failure:
                complete?(false)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditTopicViewController {
            vc.mode = .brandNew
        }
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        tutorialManager?.showTutorial()
    }
}

extension ManagementRootViewController: TutorialSupport {
    func stepOpened(stepCount: Int) {
        
    }
    
    func screenName() -> TutorialName {
        return TutorialName.hostManagement
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
   
        let step1 = TutorialStep(screenName: "\(TutorialName.hostCalendar.rawValue) + 1",
                                 body: "This is the number of people\nbooking your ClickMe session\nwaiting for your approval",
                                 pointingDirection: .up,
                                 pointPosition: .edge,
                                 targetFrame: whiteContainer1.globalFrame,
                                 showDimOverlay: true,
                                 overUIWindow: true)
        tutorialSteps.append(step1)
        
        let step2 = TutorialStep(screenName: "\(TutorialName.hostCalendar.rawValue) + 2",
                                 body: "This is the number of your\nClickMe sessions happening today ",
                                 pointingDirection: .up,
                                 pointPosition: .edge,
                                 targetFrame: whiteContainer2.globalFrame,
                                 showDimOverlay: true,
                                 overUIWindow: true)
        tutorialSteps.append(step2)
        
        let step3 = TutorialStep(screenName: "\(TutorialName.hostCalendar.rawValue) + 2",
                                 body: "Start a brand new session or\nuse the template of previous ones",
                                 pointingDirection: .down,
                                 pointPosition: .edge,
                                 targetFrame: container3.globalFrame,
                                 showDimOverlay: true,
                                 overUIWindow: true)
        tutorialSteps.append(step3)
        
        return tutorialSteps
    }
}
