//
//  ChangePhoneNumberViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import UIKit
import SKCountryPicker

class ChangePhoneNumberViewController: BaseViewController {
    @IBOutlet weak var areaCodeContainer: UIView!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var areaCodeField: UITextField!
    @IBOutlet weak var phoneField: PaddedTextField!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var phoneCodeField: PaddedTextField!
    @IBOutlet weak var phoneCodeErrorLabel: UILabel!
    @IBOutlet weak var getPhoneCodeButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
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
    
    override var selectedCountry: Country? {
        didSet {
            self.areaCodeField.text = selectedCountry?.dialingCode
            self.flagImageView.image = selectedCountry?.flag
        }
    }
    
    override func setup() {
        super.setup()
        
        areaCodeContainer.addBorder()
        phoneField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        phoneField.roundCorners()
        phoneField.addBorder()
        
        phoneCodeField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        phoneCodeField.roundCorners()
        phoneCodeField.addBorder()
        
        phoneErrorLabel.text = ""
        phoneCodeErrorLabel.text = ""
        
        attachCountryPicker(to: areaCodeField)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        areaCodeField.text = "+\(userManager.user?.areaCode ?? "")"
        
        if let areaCode = userManager.user?.areaCode {
            selectedCountry = CountryManager.shared.country(withDigitCode: areaCode)
        }
        
        phoneField.text = userManager.user?.phone
    }
    
    private func validate(step1Only: Bool = false) -> Bool {
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
        
        return true
    }
    
    @IBAction func sendPhoneCode(_ sender: UIButton) {
        if validate(step1Only: true), let areaCode = areaCodeField.text, !areaCode.isEmpty,
           let phoneNumber = phoneField.text, !phoneNumber.isEmpty {
            userManager.sendPhoneCode(sender: sender, areaCode: areaCode, phone: phoneNumber)
        }
    }
    
    @IBAction func changePress(_ sender: Any) {
        if validate(),
           let areaCode = areaCodeField.text?.replacingOccurrences(of: "+", with: ""),
           let phone = phoneField.text,
           let smsCode = phoneCodeField.text  {
            userManager.changePhone(areaCode: areaCode, phone: phone, smsCode: smsCode) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                    Toast.showSuccess(with: "Phone number updated")
                }
            }
        }
    }
}

extension ChangePhoneNumberViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == areaCodeField {
            // next action
            phoneField.becomeFirstResponder()
        } else if textField == phoneField {
            // return action
            phoneField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
