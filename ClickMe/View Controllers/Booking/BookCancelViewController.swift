//
//  BookCancelViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-18.
//

import UIKit
import GrowingTextView

class BookCancelViewController: BaseScrollingViewController {
    var schedule: Schedule!
    
    @IBOutlet weak var commentTextView: GrowingTextView!
    
    private let charCountLimit = 500
    
    override func setup() {
        super.setup()
        
        commentTextView.roundCorners()
        commentTextView.addBorder()
        commentTextView.addInset()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        contentView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func confirmPress(_ sender: Any) {
        FullScreenSpinner().show()
        api.guestCancelBooking(comment: commentTextView.text ?? "", scheduleId: schedule.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            switch result {
            case .success:
                self.navigationController?.popToRootViewController(animated: true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else if error.responseCode == 490 {
                    showErrorDialog(error: "Can't cancel an ongoing session")
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
}

extension BookCancelViewController: UITextViewDelegate {
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
