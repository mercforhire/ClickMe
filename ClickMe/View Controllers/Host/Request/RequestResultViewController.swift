//
//  RequestResultViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit

class RequestResultViewController: BaseViewController {
    var accepted: Bool!
    var schedule: Schedule!
    
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private let checkmark = UIImage(systemName: "checkmark.circle")
    private let checkmarkColor = ThemeManager.shared.themeData!.greenSendIcon.hexColor
    private let xmark = UIImage(systemName: "xmark.circle")
    private let xmarkColor = UIColor.red
    
    override func setup() {
        super.setup()
        
        if accepted {
            resultImageView.image = checkmark
            resultImageView.tintColor = checkmarkColor
            resultLabel.text = "Booking accepted!"
            actionButton.setTitle("Check Schedule", for: .normal)
        } else {
            resultImageView.image = xmark
            resultImageView.tintColor = xmarkColor
            resultLabel.text = "Booking rejected!"
            actionButton.setTitle("Reply a message", for: .normal)
            actionButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
            actionButton.backgroundColor = .clear
        }
    }

    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionPress(_ sender: Any) {
        if accepted {
            dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notifications.SwitchToCalendar, object: nil, userInfo: nil)
            })
        } else {
            dismiss(animated: true, completion: {
                guard let booker = self.schedule.booker else { return }
                
                NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["user": booker])
            })
        }
    }
    
    @IBAction func donePress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
