//
//  TopicDetailViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-16.
//

import UIKit
import UILabel_Copyable
import GrowingTextView

class TopicDetailViewController: BaseViewController {
    var schedule: Schedule!
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    @IBOutlet weak var giftButton: ThemeRoundedButton!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var topicDetailsLabel: UILabel!
    
    @IBOutlet weak var commentsContainer: UIView!
    @IBOutlet weak var commentsTextView: GrowingTextView!
    
    @IBOutlet weak var confirmContainer: UIView!
    @IBOutlet weak var costBigLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var buttonsContainer: UIView!
    
    override func setup() {
        super.setup()
        
        avatar.roundCorners(style: .medium)
        giftButton.addBorder()
        commentsTextView.roundCorners()
        commentsTextView.addBorder()
        commentsTextView.addInset()
        
        title = "\(schedule.host.fullName)'s Topic"
        avatar.config(userProfile: schedule.host, clickToOpenProfile: true)
        nameLabel.text = schedule.host.fullName
        nameLabel.isCopyingEnabled = true
        
        jobLabel.text = schedule.host.jobDescription
        jobLabel.isCopyingEnabled = true
        
        categoryImage.image = schedule.mood.icon()
        dateLabel.text = schedule.timeAndDuration
        topicLabel.text = schedule.title
        topicLabel.isCopyingEnabled = true
        
        topicDetailsLabel.text = schedule.description
        topicDetailsLabel.isCopyingEnabled = true
        
        costLabel.text = "\(schedule.coin)"
        costBigLabel.text = "\(schedule.coin)"
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if schedule.status != .open || userManager.user?.identifier == schedule.host.identifier {
            commentsContainer.isHidden = true
            confirmContainer.isHidden = true
            buttonsContainer.isHidden = true
        }
        refreshLikeButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshMySavedSchedules()
        
        balanceLabel.text = "\(userManager.user?.wallet?.preferredAccount.name().capitalizingFirstLetter() ?? "") balance: \(userManager.user?.wallet?.preferredAccountAmount ?? 0)"
    }
    
    private func refreshMySavedSchedules() {
        userManager.fetchUser { [weak self] success in
            guard let self = self else { return }
            
            self.refreshLikeButton()
        }
    }
    
    @IBAction func donatePress(_ sender: Any) {
        let vc = DonateViewController.createViewController(donateTo: schedule.host)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func messageUserPress(_ sender: Any) {
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["user": schedule.host])
    }
    
    @IBAction func chatPress(_ sender: Any) {
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["user": schedule.host, "schedule": schedule!])
    }
    
    @IBAction func likePress(_ sender: Any) {
        let favoriteSchedules = userManager.user?.favoriteSchedules ?? []
        
        let completion: (Bool) -> Void = {[weak self] success in
            guard let self = self else { return }
            
            if success {
                self.refreshMySavedSchedules()
            }
        }
        
        if favoriteSchedules.contains(schedule.identifier) {
            userManager.unSaveSchedule(scheduleId: schedule.identifier, completion: completion)
        } else {
            userManager.saveSchedule(scheduleId: schedule.identifier, completion: completion)
        }
    }

    private func refreshLikeButton() {
        let favoriteSchedules = userManager.user?.favoriteSchedules ?? []
        
        let heartEmpty = UIImage(systemName: "heart")!
        let heartFilled = UIImage(systemName: "heart.fill")!
        
        favoriteButton.setImage(favoriteSchedules.contains(schedule.identifier) ? heartFilled : heartEmpty, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        FullScreenSpinner().show()
        api.bookSchedule(scheduleId: schedule.identifier, comment: commentsTextView.text ?? "") { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success:
                self.performSegue(withIdentifier: "goToConfirmation", sender: self)
            case .failure(let error):
//                462
//                SCHEDULE_BOOKED: Schedule has been booked
//
//                464
//                USER_BLOCK: User has been blocked by host
//
//                465
//                NOT_ENOUGH_COINS: User doesn’t have enough coins to book this schedule
                
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else if error.responseCode == 462 {
                    showErrorDialog(error: "Schedule has already been booked.")
                } else if error.responseCode == 464 {
                    showErrorDialog(error: "You has been blocked by host")
                } else if error.responseCode == 465 {
                    showErrorDialog(error: "Not have enough coins to book this schedule.")
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
}
