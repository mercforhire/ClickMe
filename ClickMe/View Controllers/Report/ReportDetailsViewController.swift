//
//  ReportDetailsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-14.
//

import UIKit
import GrowingTextView

class ReportDetailsViewController: BaseScrollingViewController {
    var userId: Int!
    var reason: String = ""
    
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    private let charCountLimit = 500
    
    override func setup() {
        super.setup()
        
        reasonLabel.text = reason
        textView.text = ""
        textView.roundCorners()
        textView.addBorder()
        textView.addInset()
        charCountLabel.text = "\(textView.text.count)/\(charCountLimit)"
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func submitPressed(_ sender: UIButton) {
        FullScreenSpinner().show()
        api.reportUser(otherUserId: userId, reason: reason) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            switch result {
            case .success:
                self.showThanks()
            case .failure(let error):
                guard let errorCode = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                if errorCode == 465 {
                    showErrorDialog(error: "Already reported this user.")
                } else {
                    error.showErrorDialog()
                }
            }
        }
    }
    
    private func showThanks() {
        let ac = UIAlertController(title: "", message: "Thank you for reporting, we will take action within 1 day.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { [weak self] result in
            guard let self = self else { return }
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
}

extension ReportDetailsViewController: UITextViewDelegate {
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
    
    func textViewDidChange(_ textView: UITextView) {
        charCountLabel.text = "\(textView.text.count)/\(charCountLimit)"
    }
}
