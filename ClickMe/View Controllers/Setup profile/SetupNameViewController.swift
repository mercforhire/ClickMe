//
//  SetupNameViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-09.
//

import UIKit

class SetupNameViewController: BaseViewController {
    @IBOutlet weak var firstNameField: PaddedTextField!
    @IBOutlet weak var lastNameField: PaddedTextField!
    @IBOutlet weak var nextButton: ThemeRoundedButton!
    
    override func setup() {
        super.setup()
        
        firstNameField.roundCorners()
        firstNameField.addBorder()
        firstNameField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        lastNameField.roundCorners()
        lastNameField.addBorder()
        lastNameField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstNameField.text = userManager.user?.firstName
        lastNameField.text = userManager.user?.lastName
    }
    
    private func validate() -> Bool {
        if (firstNameField.text ?? "").isEmpty {
            showErrorDialog(error: "Please fill first name")
            return false
        } else if let name = firstNameField.text?.trim(), !Validator.validate(string: name, validation: .isAProperName) {
            showErrorDialog(error: "Please enter a valid first name")
            return false
        } else if (lastNameField.text ?? "").isEmpty {
            showErrorDialog(error: "Please fill last name")
            return false
        } else if let name = lastNameField.text?.trim(), !Validator.validate(string: name, validation: .isAProperName) {
            showErrorDialog(error: "Please enter a valid last name")
            return false
        }
        
        return true
    }
    
    @IBAction func nextPress(_ sender: Any) {
        if validate() {
            var updateForm = UpdateUserParams()
            updateForm.firstName = firstNameField.text?.trim() ?? ""
            updateForm.lastName = lastNameField.text?.trim() ?? ""
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                self.goToNextScreen()
            }
        }
    }
    
    private func goToNextScreen() {
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
}

extension SetupNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            // next action
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            // return action
            lastNameField.resignFirstResponder()
        }
        
        return true
    }
}
