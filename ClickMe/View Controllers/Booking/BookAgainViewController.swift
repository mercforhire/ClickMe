//
//  BookAgainViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-20.
//

import UIKit
import GrowingTextView

class BookAgainViewController: BaseScrollingViewController {
    var schedule: Schedule!
    
    @IBOutlet weak var commentTextView: GrowingTextView!
    
    private let charCountLimit = 500
    
    
    override func setup() {
        super.setup()
        commentTextView.roundCorners()
        commentTextView.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        contentView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendPress(_ sender: Any) {
        guard let schedule = schedule, !commentTextView.text.isEmpty else {
            showErrorDialog(error: "Please write a message to host on when you would like to book again.")
            return
        }
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["user": schedule.host, "schedule": schedule, "message": commentTextView.text!])
        navigationController?.popToRootViewController(animated: false)
    }
}

extension BookAgainViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under 150 characters
        return updatedText.count <= charCountLimit
    }
}
