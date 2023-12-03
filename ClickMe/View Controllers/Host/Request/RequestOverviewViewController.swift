//
//  RequestOverviewViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit
import Kingfisher

class RequestOverviewViewController: BaseViewController {
    var schedule: Schedule!
    
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var startCallButton: UIButton!
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var messageSection: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    
    @IBOutlet weak var bottomButtonsSection: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var reviewButton: ThemeRoundedButton!
    
    private var message: String? {
        didSet {
            guard let message = message, !message.isEmpty else { return }
            
            messageSection.isHidden = false
            messageLabel.text = message
        }
    }
    
    override func setup() {
        super.setup()
        
        avatar.roundCorners()
        messageSection.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    private func refreshView() {
        guard let booker = schedule.booker else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        title = schedule.status.viewTitle()
        avatar.config(userProfile: schedule.booker!, clickToOpenProfile: true)
        nameLabel.text = booker.fullName
        jobLabel.text = booker.jobDescription
        dateLabel.text = schedule.timeAndDuration
        topicLabel.text = schedule.title
        costLabel.text = "\(schedule.coin)"
        categoryImage.image = schedule.mood.icon()
        
        switch schedule.status {
        case .finished:
            startCallButton.isHidden = true
            bottomButtonsSection.isHidden = false
            acceptButton.isHidden = true
            rejectButton.isHidden = true
            // hide reviewButton if this was hosted by someone else
            if schedule.host.identifier != userManager.user?.identifier {
                reviewButton.isHidden = true
            }
            // hide reviewButton if a guest review already exists
            else if schedule.hostReviewed {
                reviewButton.setTitle("Edit review", for: .normal)
                reviewButton.isHidden = false
            } else {
                reviewButton.setTitle("Write a review", for: .normal)
                reviewButton.isHidden = false
            }
            
        case .upcoming, .started:
            messageButton.isHidden = true
            bottomButtonsSection.isHidden = true
            container3.isHidden = true
            reviewButton.isHidden = true
            
        case .pending:
            startCallButton.isHidden = true
            bottomButtonsSection.isHidden = false
            reviewButton.isHidden = true
            
        default:
            fatalError()
        }
        
        topicDescriptionLabel.text = schedule.description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchSchedule()
        if schedule.status == .pending {
            fetchMessage()
        }
    }
    
    private func fetchSchedule(complete: ((Bool) -> Void)? = nil) {
        api.getSchedule(scheduleId: schedule.identifier) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let res):
                self.schedule = res
                self.refreshView()
                complete?(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                complete?(false)
            }
        }
    }
    
    private func fetchMessage() {
        guard let booker = schedule.booker else { return }
        
        api.getLog(scheduleId: schedule.identifier,
                   status: .pending,
                   fromUser: booker.identifier,
                   toUser: schedule.host.identifier) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let res):
                self.message = res.message
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    @IBAction func messagePressed(_ sender: Any) {
        guard let booker = schedule.booker else { return }
        
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["user": booker, "schedule": schedule!])
    }
    
    @IBAction func acceptPress(_ sender: Any) {
        FullScreenSpinner().show()
        api.approveBooking(scheduleId: schedule.identifier) { [weak self] result in
            guard let self = self else { return }
            FullScreenSpinner().hide()
            
            switch result {
            case .success:
                self.goToResult(accepted: true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    @IBAction func goToReview(_ sender: ThemeRoundedButton) {
        guard let booker = schedule.booker else { return }
        
        let vc = RateCallViewController.createFullScreenVC(callingUser: booker, schedule: schedule)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func startCallPressed(_ sender: Any) {
        FullScreenSpinner().show()
        fetchSchedule { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            if success, self.schedule.status == .upcoming || self.schedule.status == .started {
                self.performSegue(withIdentifier: "goToReadyToCall", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfileDetailsViewController, let userId = schedule.booker?.identifier {
            vc.userId = userId
        } else if let vc = segue.destination as? RequestOptionsViewController {
            vc.schedule = schedule
        } else if let vc = segue.destination as? RequestRejectOrCancelViewController {
            vc.schedule = schedule
            vc.action = .reject
        } else if let vc = segue.destination as? BookCallViewController {
            vc.schedule = schedule
        }
    }
    
    private func goToResult(accepted: Bool) {
        let vc = StoryboardManager.loadViewController(storyboard: "HostSchedule", viewControllerId: "RequestResultViewController") as! RequestResultViewController
        vc.modalPresentationStyle = .fullScreen
        vc.accepted = accepted
        vc.schedule = schedule
        present(vc, animated: true) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: false)
        }
    }
}
