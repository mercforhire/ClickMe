//
//  SignUpViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-09.
//

import UIKit
import FMSecureTextField
import M13Checkbox

class SignUpViewController: BaseScrollingViewController {
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailCodeField: PaddedTextField!
    @IBOutlet weak var emailCodeErrorLabel: UILabel!
    @IBOutlet weak var getEmailCodeButton: UIButton!
    
    @IBOutlet weak var termsCheckbox: M13Checkbox!
    @IBOutlet weak var submitButton: UIButton!
    
    private var autoLogin: LoginViewController.AutoLoginMethod?
    
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
        
        emailField.roundCorners()
        emailField.addBorder()
        emailField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        emailCodeField.roundCorners()
        emailCodeField.addBorder()
        emailCodeField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        emailErrorLabel.text = ""
        emailCodeErrorLabel.text = ""
        
        termsCheckbox.boxType = .circle
        termsCheckbox.stateChangeAnimation = .fill
        
        emailContainer.isHidden = false
        
        showBackground()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        contentView.backgroundColor = themeManager.themeData?.defaultBackground.hexColor
        scrollView.backgroundColor = contentView.backgroundColor
        scrollView.subviews[0].backgroundColor = contentView.backgroundColor

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        if termsCheckbox.checkState != .checked {
            showErrorDialog(error: "Must agree to the Terms of Use and Privacy Policy")
            return
        }
        
        if validate() {
            guard let email = emailField.text, !email.isEmpty,
                  let code = emailCodeField.text, !code.isEmpty else { return }
            
            FullScreenSpinner().show()
            api.signUpWithEmail(email: email, emailCode: code) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                switch result {
                case .success:
                    self.autoLogin = .email(email: email, code: code)
                    self.performSegue(withIdentifier: "goToLogin", sender: self)
                case .failure(let error):
                    guard let errorCode = error.responseCode else {
                        showNetworkErrorDialog()
                        return
                    }
                    
                    if errorCode == 401 {
                        showErrorDialog(error: "Account with the email address already exist.")
                    } else if errorCode == 413 {
                        showErrorDialog(error: "Email verification code wrong.")
                    } else {
                        error.showErrorDialog()
                    }
                }
            }
        }
    }
    
    @IBAction func termsPressed(_ sender: UIButton) {
        openURLInBrowser(url: URL(string: "https://www.cpclickme.com/terms.html")!)
    }
    
    @IBAction func privacyPressed(_ sender: UIButton) {
        openURLInBrowser(url: URL(string: "https://www.cpclickme.com/privacy.html")!)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginViewController {
            vc.autoLogin = autoLogin
        }
    }
}

extension SignUpViewController {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = validate()
    }
}
