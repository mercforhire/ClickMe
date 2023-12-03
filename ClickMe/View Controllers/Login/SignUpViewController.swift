//
//  SignUpViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-09.
//

import UIKit
import FMSecureTextField
import SKCountryPicker
import M13Checkbox

class SignUpViewController: BaseScrollingViewController {
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var areaCodeContainer: UIView!
    @IBOutlet weak var areaCodeField: UITextField!
    @IBOutlet weak var phoneField: PaddedTextField!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var phoneCodeField: PaddedTextField!
    @IBOutlet weak var phoneCodeErrorLabel: UILabel!
    @IBOutlet weak var getPhoneCodeButton: UIButton!
    
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailCodeField: PaddedTextField!
    @IBOutlet weak var emailCodeErrorLabel: UILabel!
    @IBOutlet weak var getEmailCodeButton: UIButton!
    
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var passwordField: FMSecureTextField!
    @IBOutlet weak var password2Field: FMSecureTextField!
    @IBOutlet weak var rule1Icon: UIImageView!
    @IBOutlet weak var rule2Icon: UIImageView!
    @IBOutlet weak var rule3Icon: UIImageView!
    @IBOutlet weak var termsCheckbox: M13Checkbox!
    
    @IBOutlet weak var submitButton: UIButton!
    
    private var autoLogin: LoginViewController.AutoLoginMethod?
    
    override var selectedCountry: Country? {
        didSet {
            self.areaCodeField.text = selectedCountry?.dialingCode
            self.flagImageView.image = selectedCountry?.flag
        }
    }
    
    var phoneErrorString: String? {
        didSet {
            if let phoneErrorString = phoneErrorString, !phoneErrorString.isEmpty {
                phoneErrorLabel.text = phoneErrorString
            } else {
                phoneErrorLabel.text = ""
            }
        }
    }
    
    var phoneCodeErrorString: String? {
        didSet {
            if let phoneCodeErrorString = phoneCodeErrorString, !phoneCodeErrorString.isEmpty {
                phoneCodeErrorLabel.text = phoneCodeErrorString
            } else {
                phoneCodeErrorLabel.text = ""
            }
        }
    }
    
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
    
    var rule1Pass: Bool = false {
        didSet {
            rule1Icon.tintColor = rule1Pass ? .green : .red
            rule1Icon.image = rule1Pass ? UIImage(systemName: "checkmark.circle")! : UIImage(systemName: "circle")!
        }
    }
    
    var rule2Pass: Bool = false {
        didSet {
            rule2Icon.tintColor = rule2Pass ? .green : .red
            rule2Icon.image = rule2Pass ? UIImage(systemName: "checkmark.circle")! : UIImage(systemName: "circle")!
        }
    }
    
    var rule3Pass: Bool = false {
        didSet {
            rule3Icon.tintColor = rule3Pass ? .green : .red
            rule3Icon.image = rule3Pass ? UIImage(systemName: "checkmark.circle")! : UIImage(systemName: "circle")!
        }
    }
    
    var mode: LoginMode = .phone {
        didSet {
            switch mode {
            case .phone:
                phoneContainer.isHidden = false
                emailContainer.isHidden = true
                phoneButton.setTitleColor(themeManager.themeData?.textLabel.hexColor, for: .normal)
                emailButton.setTitleColor(UIColor.lightGray, for: .normal)
            case .email:
                phoneContainer.isHidden = true
                emailContainer.isHidden = false
                phoneButton.setTitleColor(UIColor.lightGray, for: .normal)
                emailButton.setTitleColor(themeManager.themeData?.textLabel.hexColor, for: .normal)
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        areaCodeContainer.addBorder()
        
        phoneField.roundCorners()
        phoneField.addBorder()
        phoneField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        phoneField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        phoneCodeField.roundCorners()
        phoneCodeField.addBorder()
        phoneCodeField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        phoneCodeField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        emailField.roundCorners()
        emailField.addBorder()
        emailField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        emailCodeField.roundCorners()
        emailCodeField.addBorder()
        emailCodeField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        passwordField.roundCorners()
        passwordField.addBorder()
        passwordField.addLeftInset()
        passwordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        password2Field.roundCorners()
        password2Field.addBorder()
        password2Field.addLeftInset()
        password2Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        phoneErrorLabel.text = ""
        phoneCodeErrorLabel.text = ""
        emailErrorLabel.text = ""
        emailCodeErrorLabel.text = ""
        
        termsCheckbox.boxType = .circle
        termsCheckbox.stateChangeAnimation = .fill
        
        mode = .phone
        
        showBackground()
        attachCountryPicker(to: areaCodeField)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        contentView.backgroundColor = themeManager.themeData?.defaultBackground.hexColor
        scrollView.backgroundColor = contentView.backgroundColor
        scrollView.subviews[0].backgroundColor = contentView.backgroundColor
        
        passwordField.applyTheme()
        password2Field.applyTheme()
        
        mode = { self.mode }()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectedCountry = getCurrentCountry()
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
            switch mode {
            case .phone:
                guard let areaCode = areaCodeField.text?.numbers, !areaCode.isEmpty,
                      let phoneNumber = phoneField.text?.numbers, !phoneNumber.isEmpty,
                      let code = phoneCodeField.text?.numbers, !code.isEmpty else { return }
                
                FullScreenSpinner().show()
                api.signUpWithPhone(areaCode: areaCode, phone: phoneNumber, smsCode: code) { [weak self] result in
                    guard let self = self else { return }
                    
                    FullScreenSpinner().hide()
                    switch result {
                    case .success:
                        self.autoLogin = .phone(areaCode: areaCode, phoneNumber: phoneNumber, code: code)
                        self.performSegue(withIdentifier: "goToLogin", sender: self)
                    case .failure(let error):
                        guard let errorCode = error.responseCode else {
                            showNetworkErrorDialog()
                            return
                        }
                        
                        if errorCode == 403 {
                            showErrorDialog(error: "Account with the phone number already exist")
                        } else if errorCode == 415 {
                            showErrorDialog(error: "SMS verification code wrong.")
                        } else {
                            error.showErrorDialog()
                        }
                        
                    }
                }
            case .email:
                guard let email = emailField.text, !email.isEmpty,
                      let code = emailCodeField.text, !code.isEmpty,
                      let password = passwordField.text, !password.isEmpty else { return }
                
                FullScreenSpinner().show()
                api.signUpWithEmail(email: email, emailCode: code, password: password) { [weak self] result in
                    guard let self = self else { return }
                    
                    FullScreenSpinner().hide()
                    switch result {
                    case .success:
                        self.autoLogin = .email(email: email, password: password)
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
    }
    
    @IBAction func termsPressed(_ sender: UIButton) {
        openURLInBrowser(url: URL(string: "https://www.cpclickme.com/terms.html")!)
    }
    
    @IBAction func privacyPressed(_ sender: UIButton) {
        openURLInBrowser(url: URL(string: "https://www.cpclickme.com/privacy.html")!)
    }
    
    private func validate(step1Only: Bool = false) -> Bool {
        switch mode {
        case .phone:
            if (areaCodeField.text ?? "").isEmpty {
                phoneErrorString = "* Area code is empty"
                return false
            } else if let areaCode = areaCodeField.text?.replacingOccurrences(of: "+", with: ""),
                      !Validator.validate(string: areaCode, validation: .numeric) {
                phoneErrorString = "* Area code is invalid"
                return false
            } else if (phoneField.text ?? "").isEmpty {
                phoneErrorString = "* Phone number is empty"
                return false
            } else if let phoneNumber = phoneField.text,
                      !Validator.validate(string: phoneNumber, validation: .numeric) {
                phoneErrorString = "* Phone number is invalid"
                return false
            }
            
            if step1Only {
                phoneErrorString = ""
                return true
            }
            
            if (phoneCodeField.text ?? "").isEmpty {
                phoneErrorString = ""
                phoneCodeErrorString = "* Verification code is empty"
                return false
            } else {
                phoneErrorString = ""
                phoneCodeErrorString = ""
            }
        
        case .email:
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
            
            if (passwordField.text ?? "").isEmpty {
                rule1Pass = false
                rule2Pass = false
                return false
            } else if let error = PasswordValidator.validate(string: (passwordField.text ?? "")) {
                if error == "Must be 8 or more characters" || error == "Must be 32 or less characters" {
                    rule1Pass = false
                    rule2Pass = false
                } else {
                    rule1Pass = true
                    rule2Pass = false
                }
            } else {
                rule1Pass = true
                rule2Pass = true
            }
            
            if (password2Field.text ?? "").isEmpty {
                rule3Pass = false
                return false
            } else if password2Field.text != passwordField.text {
                rule3Pass = false
                return false
            } else {
                rule3Pass = true
            }
        }
        
        return true
    }
    
    
    @IBAction func phonePress(_ sender: Any) {
        mode = .phone
    }
    
    @IBAction func emailPress(_ sender: Any) {
        mode = .email
    }
    
    @IBAction func sendPhoneCode(_ sender: UIButton) {
        if validate(step1Only: true), let areaCode = areaCodeField.text, !areaCode.isEmpty,
           let phoneNumber = phoneField.text, !phoneNumber.isEmpty {
            userManager.sendPhoneCode(sender:sender, areaCode: areaCode, phone: phoneNumber)
        }
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == areaCodeField || textField == phoneField {
            textField.text = textField.text?.numbers
        } else if textField == passwordField || textField == password2Field {
            _ = validate()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch mode {
        case .phone:
            if textField == areaCodeField {
                // next action
                phoneField.becomeFirstResponder()
            } else if textField == phoneField {
                // return action
                phoneField.resignFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        case .email:
            if textField == passwordField {
                // next action
                _ = password2Field.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
}
