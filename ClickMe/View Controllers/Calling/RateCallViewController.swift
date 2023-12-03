//
//  RateCallViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-24.
//

import UIKit
import Cosmos
import Kingfisher

class RateCallViewController: BaseViewController {
    var callingUser: ListUser!
    var schedule: Schedule!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var stars: CosmosView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var reviewType: ReviewType!
    private var review: Review? {
        didSet {
            if review != nil {
                // edit mode
                stars.isUserInteractionEnabled = false
            }
        }
    }
    
    private var donationAmount: Int? {
        didSet {
            if let _ = donationAmount {
                donateButton.setTitle("Thank you", for: .normal)
                donateButton.isEnabled = false
            }
        }
    }
    
    static func createFullScreenVC(callingUser: ListUser, schedule: Schedule) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Calling", viewControllerId: "RateCallViewController") as! RateCallViewController
        vc.schedule = schedule
        vc.callingUser = callingUser
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    override func setup() {
        super.setup()
        
        avatar.roundCorners(style: .medium)
        doneButton.roundCorners()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.theme == .light ? themeManager.themeData!.indigo.hexColor : themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reviewType = schedule.host.identifier == userManager.user?.identifier ? .asHost : .asGuest
        
        if let urlString = callingUser.avatar?.smallUrl, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = callingUser.defaultAvatar
        }
        nameLabel.text = callingUser.fullName
        jobLabel.text = callingUser.jobDescription
        
        switch reviewType {
        case .asHost:
            if let review = schedule.hostReview {
                self.review = review
                reviewLabel.text = review.body
                stars.rating = Double(review.rating)
                addReviewButton.setTitle("", for: .normal)
            } else {
                reviewLabel.text = ""
                stars.rating = 0.0
            }
        case .asGuest:
            if let review = schedule.guestReview {
                self.review = review
                reviewLabel.text = review.body
                stars.rating = Double(review.rating)
                addReviewButton.setTitle("", for: .normal)
            } else {
                reviewLabel.text = ""
                stars.rating = 0.0
            }
        default:
            fatalError()
        }
    }
    
    @IBAction func addReviewPress(_ sender: Any) {
        let vc = EditTextViewController.createViewController(title: "Review for \(callingUser.shortName)",
                                                             initialText: reviewLabel.text ?? "",
                                                             maxCharCount: 500,
                                                             completion:
            { [weak self] result in
                guard let self = self else { return }
                
                self.reviewLabel.text = result
                self.addReviewButton.setTitle("", for: .normal)
            })
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func donatePress(_ sender: Any) {
        let vc = DonateViewController.createViewController(donateTo: callingUser, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func donePress(_ sender: Any) {
        if stars.rating == 0.0 || reviewLabel.text?.isEmpty ?? true {
            showErrorDialog(error: "Please fill out the stars rating and review.")
            return
        }
        
        if (reviewLabel.text ?? "").count < 10 {
            showErrorDialog(error: "Please type a bit more for the review.")
            return
        }
        
        FullScreenSpinner().show()
        if let review = review {
            let params = UpdateReviewParams(scheduleId: schedule.identifier, commentId: review.identifier, reviewType: reviewType, rating: Int(stars.rating), comment: reviewLabel.text ?? "")
            api.updateReview(param: params) {  [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                }
            }
        } else {
            let reviewType: ReviewType = schedule.host.identifier == userManager.user?.identifier ? .asHost : .asGuest
            let params = CreateReviewParams(scheduleId: schedule.identifier, reviewType: reviewType, rating: stars.rating, comment: reviewLabel.text ?? "")
            api.postReview(param: params) {  [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self.dismiss(animated: true, completion: nil)
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
    }
    
    @IBAction func skipPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension RateCallViewController: DonateViewControllerDelegate {
    func donatedAmount(amount: Int) {
        donationAmount = amount
    }
}
