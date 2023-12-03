//
//  ChangeEmailViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import UIKit

class ChangeEmailViewController: BaseViewController {
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailCodeField: PaddedTextField!
    @IBOutlet weak var emailCodeErrorLabel: UILabel!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var emailErrorString: String? {
        didSet {
            if let emailErrorString = emailErrorString, !emailErrorString.isEmpty {
                emailErrorLabel.text = emailErrorString
            } else {
                emailErrorLabel.text = ""
            }
        }
    }
    
    var emailCodeErrorString: String? {
        didSet {
            if let emailCodeErrorString = emailCodeErrorString, !emailCodeErrorString.isEmpty {
                emailCodeErrorLabel.text = emailCodeErrorString
            } else {
                emailCodeErrorLabel.text = ""
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        emailField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        emailCodeField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        emailField.roundCorners()
        emailField.addBorder()
        
        emailCodeField.roundCorners()
        emailCodeField.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailErrorLabel.text = ""
        emailCodeErrorLabel.text = ""
    }
    
    private func validate(step1Only: Bool = false) -> Bool {
        if (emailField.text ?? "").isEmpty {
            emailErrorString = "* Email is empty"
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            emailErrorString = "* Invalid email"
            return false
        }
        
        if step1Only {
            emailErrorString = ""
            return true
        }
        
        if (emailCodeField.text ?? "").isEmpty {
            emailErrorString = ""
            emailCodeErrorString = "* Verification code is empty"
            return false
        } else {
            emailErrorString = ""
            emailCodeErrorString = ""
        }
        return true
    }
    
    @IBAction func sendEmailCode(_ sender: UIButton) {
        if validate(step1Only: true), let email = emailField.text, !email.isEmpty  {
            userManager.sendEmailCode(sender: sender, email: email, checkForEmailExistence: false)
        }
    }
    
    @IBAction func changePress(_ sender: Any) {
        if validate(),
           let newEmail = emailField.text,
           let emailCode = emailCodeField.text {
            userManager.changeEmail(newEmail: newEmail, emailCode: emailCode)
            { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                    Toast.showSuccess(with: "Email updated")
                }
            }
        }
    }
}

extension ChangeEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
