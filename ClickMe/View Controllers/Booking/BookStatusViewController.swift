//
//  BookStatusViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-10.
//

import UIKit

class BookStatusViewController: BaseViewController {
    var schedule: Schedule!
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var giftButton: UIButton!
    @IBOutlet weak var startCallButton: UIButton!
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var topicDetailsLabel: UILabel!
    
    @IBOutlet weak var bookAgainButton: ThemeRoundedButton!
    @IBOutlet weak var reviewButton: ThemeRoundedButton!
    
    override func setup() {
        super.setup()
        
        avatar.roundCorners()
        giftButton.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchSchedule()
    }
    
    func refreshView() {
        avatar.config(userProfile: schedule.host, clickToOpenProfile: true)
        nameLabel.text = schedule.host.fullName
        jobLabel.text = schedule.host.jobDescription
        categoryImage.image = schedule.mood.icon()
        dateLabel.text = schedule.timeAndDuration
        topicLabel.text = schedule.title
        costLabel.text = "\(schedule.coin)"
        topicDetailsLabel.text = schedule.description
        
        switch schedule.status {
        case .open:
            startCallButton.isHidden = true
            reviewButton.isHidden = true
            bookAgainButton.isHidden = true
        case .pending:
            startCallButton.isHidden = true
            reviewButton.isHidden = true
            bookAgainButton.isHidden = true
        case .started, .upcoming:
            startCallButton.isHidden = false
            reviewButton.isHidden = true
            bookAgainButton.isHidden = true
        case .finished:
            startCallButton.isHidden = true
            reviewButton.isHidden = false
            bookAgainButton.isHidden = false
            
            // hide reviewButton if this was booked by someone else
            if schedule.booker?.identifier != userManager.user?.identifier {
                reviewButton.isHidden = true
            }
            // hide reviewButton if a guest review already exists
            else if schedule.guestReviewed {
                reviewButton.setTitle("Edit review", for: .normal)
            } else {
                reviewButton.setTitle("Write a review", for: .normal)
            }
        default:
            startCallButton.isHidden = true
            reviewButton.isHidden = true
            bookAgainButton.isHidden = true
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
    
    @IBAction func donatePress(_ sender: Any) {
        let vc = DonateViewController.createViewController(donateTo: schedule.host)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func messagePress(_ sender: Any) {
        guard let schedule = schedule else { return }
        
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["user": schedule.host, "schedule": schedule])
    }
    
    @IBAction func reviewPress(_ sender: Any) {
        let vc = RateCallViewController.createFullScreenVC(callingUser: schedule.host, schedule: schedule)
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
        if let vc = segue.destination as? BookCallViewController {
            vc.schedule = schedule
        } else if let vc = segue.destination as? BookOptionsViewController {
            vc.schedule = schedule
        } else if let vc = segue.destination as? BookAgainViewController {
            vc.schedule = schedule
        }
    }
}
