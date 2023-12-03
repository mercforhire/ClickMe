//
//  LoginViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit
import FMSecureTextField
import SKCountryPicker

class LoginViewController: BaseScrollingViewController {
    enum AutoLoginMethod {
        case email(email: String, password: String)
        case phone(areaCode: String, phoneNumber: String, code: String)
    }
    
    var autoLogin: AutoLoginMethod?
    
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
    @IBOutlet weak var passwordField: FMSecureTextField!
    @IBOutlet weak var passErrorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
    
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
                phoneField.layer.borderColor = UIColor.red.cgColor
                phoneField.layer.borderWidth = 1.0
            } else {
                phoneErrorLabel.text = ""
                phoneField.layer.borderWidth = 0
            }
        }
    }
    
    var phoneCodeErrorString: String? {
        didSet {
            if let phoneCodeErrorString = phoneCodeErrorString, !phoneCodeErrorString.isEmpty {
                phoneCodeErrorLabel.text = phoneCodeErrorString
                phoneCodeField.layer.borderColor = UIColor.red.cgColor
                phoneCodeField.layer.borderWidth = 1.0
            } else {
                phoneCodeErrorLabel.text = ""
                phoneCodeField.layer.borderWidth = 0
            }
        }
    }
    
    var emailErrorString: String? {
        didSet {
            if let emailErrorString = emailErrorString, !emailErrorString.isEmpty {
                emailErrorLabel.text = emailErrorString
                emailField.layer.borderColor = UIColor.red.cgColor
                emailField.layer.borderWidth = 1.0
            } else {
                emailErrorLabel.text = ""
                emailField.layer.borderWidth = 0
            }
        }
    }
    
    var passErrorString: String? {
        didSet {
            if let passErrorString = passErrorString, !passErrorString.isEmpty {
                passErrorLabel.text = passErrorString
                passwordField.layer.borderColor = UIColor.red.cgColor
                passwordField.layer.borderWidth = 1.0
            } else {
                passErrorLabel.text = ""
                passwordField.layer.borderWidth = 0
            }
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
                forgetButton.isHidden = true
            case .email:
                phoneContainer.isHidden = true
                emailContainer.isHidden = false
                phoneButton.setTitleColor(UIColor.lightGray, for: .normal)
                emailButton.setTitleColor(themeManager.themeData?.textLabel.hexColor, for: .normal)
                forgetButton.isHidden = false
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
        
        passwordField.roundCorners()
        passwordField.addBorder()
        passwordField.addLeftInset()
        
        phoneErrorLabel.text = ""
        phoneCodeErrorLabel.text = ""
        emailErrorLabel.text = ""
        passErrorLabel.text = ""
        
        mode = .phone
        
        showBackground()
        attachCountryPicker(to: areaCodeField)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        contentView.backgroundColor = themeManager.themeData?.defaultBackground.hexColor
        scrollView.backgroundColor = contentView.backgroundColor
        scrollView.subviews[0].backgroundColor = contentView.backgroundColor
        
        mode = { self.mode }()
        passwordField.applyTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        if let lastUsedAreaCode = appSettings.getLastUsedAreaCode() {
            areaCodeField.text = lastUsedAreaCode
        } else {
            selectedCountry = getCurrentCountry()
        }
        
        phoneField.text = appSettings.getLastUsedPhone()
        emailField.text = appSettings.getLastUsedEmail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let autoLogin = autoLogin {
            switch autoLogin {
            case .phone(let areaCode, let phoneNumber, let code):
                mode = .phone
                areaCodeField.text = areaCode
                phoneField.text = phoneNumber
                phoneCodeField.text = code
                loginPressed(loginButton)
            case .email(let email, let password):
                mode = .email
                emailField.text = email
                passwordField.text = password
                loginPressed(loginButton)
            }
            self.autoLogin = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if validate() {
            switch mode {
            case .phone:
                guard let areaCode = areaCodeField.text, !areaCode.isEmpty,
                    let phoneNumber = phoneField.text, !phoneNumber.isEmpty,
                      let code = phoneCodeField.text, !code.isEmpty else { return }
                
                appSettings.setLastUsedPhone(phone: phoneNumber)
                
                FullScreenSpinner().show()
                
                var isSuccess: Bool = true
                let queue = DispatchQueue.global(qos: .default)
                
                queue.async { [weak self] in
                    guard let self = self else { return }
                    
                    let semaphore = DispatchSemaphore(value: 0)
                    
                    self.userManager.login(areaCode: areaCode, phone: phoneNumber, verifyCode: code) { success in
                        isSuccess = success
                        semaphore.signal()
                    }
                    semaphore.wait()
                    
                    guard isSuccess else {
                        DispatchQueue.main.async {
                            FullScreenSpinner().hide()
                        }
                        return
                    }
                    
                    self.userManager.fetchUser { success in
                        isSuccess = success
                        semaphore.signal()
                    }
                    semaphore.wait()
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        FullScreenSpinner().hide()
                        
                        if isSuccess {
                            self.proceedPassLogin()
                        }
                    }
                }

            case .email:
                guard let email = emailField.text, !email.isEmpty,
                      let password = passwordField.text, !password.isEmpty else { return }
                
                appSettings.setLastUsedEmail(email: email)
                
                FullScreenSpinner().show()
                var isSuccess: Bool = true
                let queue = DispatchQueue.global(qos: .background)
                
                queue.async { [weak self] in
                    guard let self = self else { return }
                    
                    let semaphore = DispatchSemaphore(value: 0)
                    
                    self.userManager.login(email: email, password: password) { success in
                        isSuccess = success
                        semaphore.signal()
                    }
                    semaphore.wait()
                    
                    guard isSuccess else {
                        DispatchQueue.main.async {
                            FullScreenSpinner().hide()
                        }
                        return
                    }
                    
                    self.userManager.fetchUser { success in
                        isSuccess = success
                        semaphore.signal()
                    }
                    semaphore.wait()
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        FullScreenSpinner().hide()
                        
                        if isSuccess {
                            self.proceedPassLogin()
                        }
                    }
                }
            }
        }
    }
    
    private func validate() -> Bool {
        switch mode {
        case .phone:
            if (phoneField.text ?? "").isEmpty {
                phoneErrorString = "* Phone number is empty"
                return false
            } else if let phoneNumber = phoneField.text,
                      !Validator.validate(string: phoneNumber, validation: .numeric) {
                phoneErrorString = "* Phone number is invalid"
                return false
            } else if (phoneCodeField.text ?? "").isEmpty {
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
            } else {
                emailErrorString = ""
            }
            
            if (passwordField.text ?? "").isEmpty {
                passErrorString = "* Password is empty"
                return false
            } else {
                passErrorString = ""
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
        guard let areaCode = areaCodeField.text, !areaCode.isEmpty, let phoneNumber = phoneField.text, !phoneNumber.isEmpty else { return }
        
        userManager.sendPhoneCode(sender: sender, areaCode: areaCode, phone: phoneNumber)
    }
    
    private func proceedPassLogin() {
        api.clearBadgeCount { _ in
            
        }
        
        if userManager.setupManager.isProfileFullySetup() {
            if let lastMode = appSettings.getLastUsedMode() {
                switch lastMode {
                case "guest":
                    performSegue(withIdentifier: "goToMain", sender: self)
                case "host":
                    performSegue(withIdentifier: "goToHost", sender: self)
                default:
                    performSegue(withIdentifier: "goToMain", sender: self)
                }
            } else {
                performSegue(withIdentifier: "goToMain", sender: self)
            }
        } else {
            userManager.setupManager.goToAppropriateSetupView(vc: self)
        }
    }
    
    private var tappedNumber: Int = 0 {
        didSet {
            if tappedNumber >= 10 {
                let ac = UIAlertController(title: nil, message: "Choose environment", preferredStyle: .actionSheet)
                let action1 = UIAlertAction(title: "Production\(AppSettingsManager.shared.getEnvironment() == .production ? "(Selected)" : "")", style: .default) { [weak self] action in
                    ClickAPI.shared.baseURL = Environments.production.hostUrl()
                    AppSettingsManager.shared.setEnvironment(environments: .production)
                    self?.clearFields()
                }
                ac.addAction(action1)
                
                let action2 = UIAlertAction(title: "Development\(AppSettingsManager.shared.getEnvironment() == .development ? "(Selected)" : "")", style: .default) { [weak self] action in
                    ClickAPI.shared.baseURL = Environments.development.hostUrl()
                    AppSettingsManager.shared.setEnvironment(environments: .development)
                    self?.clearFields()
                }
                ac.addAction(action2)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                    self?.tappedNumber = 0
                }
                ac.addAction(cancelAction)
                present(ac, animated: true)
            }
        }
    }
    
    @IBAction private func cheatButtonPress(_ sender: UIButton) {
        print("CheatButton Pressed")
        tappedNumber = tappedNumber + 1
    }
    
    private func clearFields() {
        UserManager.shared.logOut()
        tappedNumber = 0
    }
}

extension LoginViewController {    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == phoneCodeField || textfield == phoneField {
            textfield.text = textfield.text?.numbers
        }
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
            if textField == emailField {
                // next action
                _ = passwordField.becomeFirstResponder()
            } else if textField == passwordField {
                // return action
                passwordField.resignFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
}
