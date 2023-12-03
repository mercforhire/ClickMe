//
//  ChangePasswordViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import UIKit
import FMSecureTextField

class ChangePasswordViewController: BaseViewController {
    @IBOutlet weak var oldPasswordField: FMSecureTextField!
    @IBOutlet weak var passwordField: FMSecureTextField!
    @IBOutlet weak var password2Field: FMSecureTextField!
    @IBOutlet weak var rule1Icon: UIImageView!
    @IBOutlet weak var rule2Icon: UIImageView!
    @IBOutlet weak var rule3Icon: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    var rule1Pass: Bool = false {
        didSet {
            rule1Icon.image = rule1Pass ? UIImage(systemName: "checkmark.circle.fill")! : UIImage(systemName: "circle")!
        }
    }
    
    var rule2Pass: Bool = false {
        didSet {
            rule2Icon.image = rule2Pass ? UIImage(systemName: "checkmark.circle.fill")! : UIImage(systemName: "circle")!
        }
    }
    
    var rule3Pass: Bool = false {
        didSet {
            rule3Icon.image = rule3Pass ? UIImage(systemName: "checkmark.circle.fill")! : UIImage(systemName: "circle")!
        }
    }
    
    override func setup() {
        super.setup()
        
        oldPasswordField.addLeftInset()
        oldPasswordField.roundCorners()
        oldPasswordField.addBorder()
        
        passwordField.addLeftInset()
        passwordField.roundCorners()
        passwordField.addBorder()
        
        password2Field.addLeftInset()
        password2Field.roundCorners()
        password2Field.addBorder()
        
        if userManager.user?.email?.isEmpty ?? true {
            title = "Create Password"
            oldPasswordField.isHidden = true
        } else {
            title = "Change Password"
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        oldPasswordField.applyTheme()
        passwordField.applyTheme()
        password2Field.applyTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func donePress(_ sender: Any) {
        if validate(),
            let oldPassword = oldPasswordField.text,
            let password = password2Field.text {
             userManager.changePassword(oldPassword: oldPassword, password: password)
             { [weak self] success in
                 guard let self = self else { return }
                 
                 if success {
                     self.navigationController?.popViewController(animated: true)
                     Toast.showSuccess(with: "Password updated")
                 }
             }
        }
    }
    
    private func validate() -> Bool {
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
            return false
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
        
        return true
    }
}

extension ChangePasswordViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordField {
            // next action
            _ = password2Field.becomeFirstResponder()
        } else if textField == password2Field {
            // next action
            textField.resignFirstResponder()
        }
        
        return true
    }
}
