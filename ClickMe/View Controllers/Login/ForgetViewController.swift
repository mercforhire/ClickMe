//
//  ForgetViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit
import FMSecureTextField

class ForgetViewController: BaseScrollingViewController {
    
    @IBOutlet weak var fieldsContainer: UIView!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var sendEmailCodeButton: UIButton!
    @IBOutlet weak var code1Field: UITextField!
    @IBOutlet weak var code2Field: UITextField!
    @IBOutlet weak var code3Field: UITextField!
    @IBOutlet weak var code4Field: UITextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    
    @IBOutlet weak var newPassField: FMSecureTextField!
    @IBOutlet weak var newPassErrorLabel: UILabel!
    @IBOutlet weak var retypeField: FMSecureTextField!
    @IBOutlet weak var retypeErrorLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!

    var emailErrorString: String? {
        didSet {
            if let emailErrorString = emailErrorString, !emailErrorString.isEmpty {
                emailErrorLabel.text = emailErrorString
            } else {
                emailErrorLabel.text = ""
            }
        }
    }
    
    var codeString: String? {
        didSet {
            if let codeString = codeString, !codeString.isEmpty {
                codeErrorLabel.text = codeString
            } else {
                codeErrorLabel.text = ""
            }
        }
    }
    
    var newPassErrorString: String? {
        didSet {
            if let newPassErrorString = newPassErrorString, !newPassErrorString.isEmpty {
                newPassErrorLabel.text = newPassErrorString
            } else {
                newPassErrorLabel.text = ""
            }
        }
    }
    
    var retypeErrorString: String? {
        didSet {
            if let retypeErrorString = retypeErrorString, !retypeErrorString.isEmpty {
                retypeErrorLabel.text = retypeErrorString
            } else {
                retypeErrorLabel.text = ""
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        emailField.roundCorners()
        emailField.addBorder()
        emailField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        code1Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code2Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code3Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code4Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        newPassField.roundCorners()
        newPassField.addBorder()
        newPassField.addLeftInset()
        
        retypeField.roundCorners()
        retypeField.addBorder()
        retypeField.addLeftInset()
        
        emailErrorLabel.text = ""
        codeErrorLabel.text = ""
        newPassErrorLabel.text = ""
        retypeErrorLabel.text = ""
        
        showBackground()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        contentView.backgroundColor = themeManager.themeData?.defaultBackground.hexColor
        scrollView.backgroundColor = contentView.backgroundColor
        scrollView.subviews[0].backgroundColor = contentView.backgroundColor
        
        newPassField.applyTheme()
        retypeField.applyTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func sendCodeByMail(_ sender: UIButton) {
        if validate(step1Only: true) {
            
            guard let email = emailField.text, !email.isEmpty else { return }
            
            userManager.sendEmailCode(sender: sender, email: email, checkForEmailExistence: true)
        }
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        if validate() {
            let emailCode = "\(code1Field.text ?? "")\(code2Field.text ?? "")\(code3Field.text ?? "")\(code4Field.text ?? "")"
            
            guard let email = emailField.text,
                  !email.isEmpty,
                  !emailCode.isEmpty,
                  let newPassword = newPassField.text,
                  !newPassword.isEmpty,
                  emailCode.count == 4 else { return }
            
            FullScreenSpinner().show()
            api.forgetPassword(email: email, emailCode: emailCode, newPassword: newPassword) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                switch result {
                case .success:
                    _ = self.navigationController?.popToViewControllerOfClass(kind: LoginViewController.self)
                case .failure(let error):
                    guard let errorCode = error.responseCode else {
                        showNetworkErrorDialog()
                        return
                    }
                    
                    if errorCode == 413 {
                        showErrorDialog(error: "Email verification code wrong.")
                    } else if errorCode == 416 {
                        showErrorDialog(error: "Account with this email address is not found.")
                    } else {
                        error.showErrorDialog()
                    }
                }
            }
        }
    }
    
    private func validate(step1Only: Bool = false) -> Bool {
        if (emailField.text ?? "").isEmpty {
            emailErrorString = "* Email is empty"
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            emailErrorString = "* Invalid email"
            return false
        } else {
            emailErrorString = ""
        }
        
        if step1Only {
            return true
        }
        
        if (code1Field.text ?? "").isEmpty || (code2Field.text ?? "").isEmpty || (code3Field.text ?? "").isEmpty || (code4Field.text ?? "").isEmpty {
            codeString = "* Code not filled"
            return false
        } else {
            codeString = ""
        }
        
        if (newPassField.text ?? "").isEmpty {
            newPassErrorString = "* Password is empty"
            return false
        } else if let error = PasswordValidator.validate(string: (newPassField.text ?? "")) {
            newPassErrorString = "* \(error)"
            return false
        } else {
            newPassErrorString = ""
        }
        
        if (retypeField.text ?? "").isEmpty {
            retypeErrorString = "* Password is empty"
            return false
        } else if newPassField.text != retypeField.text {
            retypeErrorString = "* Password not match"
            return false
        } else {
            retypeErrorString = ""
        }
        
        return true
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == code1Field {
            if (textfield.text ?? "").isEmpty {
                
            } else {
                code2Field.becomeFirstResponder()
            }
        } else if textfield == code2Field {
            if (textfield.text ?? "").isEmpty {
                code1Field.becomeFirstResponder()
            } else {
                code3Field.becomeFirstResponder()
            }
        } else if textfield == code3Field {
            code4Field.becomeFirstResponder()
            if (textfield.text ?? "").isEmpty {
                code2Field.becomeFirstResponder()
            } else {
                code4Field.becomeFirstResponder()
            }
        } else if textfield == code4Field {
            if (textfield.text ?? "").isEmpty {
                code3Field.becomeFirstResponder()
            }
        }
    }
}

extension ForgetViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            textField.resignFirstResponder()
        } else if textField == code1Field {
            code2Field.becomeFirstResponder()
        } else if textField == code2Field {
            code3Field.becomeFirstResponder()
        } else if textField == code3Field {
            code4Field.becomeFirstResponder()
        } else if textField == code4Field {
            code4Field.resignFirstResponder()
            resetPressed(resetButton)
        } else if textField == newPassField {
            // next action
            _ = retypeField.becomeFirstResponder()
        } else if textField == retypeField {
            // next action
            textField.resignFirstResponder()
            resetPressed(resetButton)
        }
        
        return true
    }
}
