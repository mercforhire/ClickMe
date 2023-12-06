//
//  LoginViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit

class LoginViewController: BaseScrollingViewController {
    enum AutoLoginMethod {
        case email(email: String, code: String)
    }
    
    var autoLogin: AutoLoginMethod?
    
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var codeField: PaddedTextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
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
    
    var codeErrorString: String? {
        didSet {
            if let passErrorString = codeErrorString, !passErrorString.isEmpty {
                codeErrorLabel.text = passErrorString
                codeField.layer.borderColor = UIColor.red.cgColor
                codeField.layer.borderWidth = 1.0
            } else {
                codeErrorLabel.text = ""
                codeField.layer.borderWidth = 0
            }
        }
    }
    
    
    override func setup() {
        super.setup()
        
        emailField.roundCorners()
        emailField.addBorder()
        emailField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        codeField.roundCorners()
        codeField.addBorder()
        codeField.addLeftInset()
        
        emailErrorLabel.text = ""
        codeErrorLabel.text = ""
        
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
            case .email(let email, let token):
                emailField.text = email
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
            guard let email = emailField.text, !email.isEmpty,
                  let code = codeField.text, !code.isEmpty else { return }
            
            appSettings.setLastUsedEmail(email: email)
            
            FullScreenSpinner().show()
            var isSuccess: Bool = true
            let queue = DispatchQueue.global(qos: .background)
            
            queue.async { [weak self] in
                guard let self = self else { return }
                
                let semaphore = DispatchSemaphore(value: 0)
                
                self.userManager.login(email: email, code: code) { success in
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
    
    
    private func validate() -> Bool {
        if (emailField.text ?? "").isEmpty {
            emailErrorString = "* Email is empty"
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            emailErrorString = "* Invalid email"
            return false
        } else {
            emailErrorString = ""
        }
        
        if (codeField.text ?? "").isEmpty {
            codeErrorString = "* Code is empty"
            return false
        } else {
            codeErrorString = ""
        }
        
        return true
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
                    AppSettingsManager.shared.setEnvironment(environments: .production)
                    self?.clearFields()
                }
                ac.addAction(action1)
                
                let action2 = UIAlertAction(title: "Development\(AppSettingsManager.shared.getEnvironment() == .development ? "(Selected)" : "")", style: .default) { [weak self] action in
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            // next action
            _ = codeField.becomeFirstResponder()
        } else if textField == codeField {
            // return action
            codeField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
