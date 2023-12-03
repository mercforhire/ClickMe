//
//  EditNameViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit

class EditNameViewController: BaseViewController {
    @IBOutlet weak var firstnameField: PaddedTextField!
    @IBOutlet weak var lastnameField: PaddedTextField!
    
    override func setup() {
        super.setup()
        
        firstnameField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        firstnameField.roundCorners()
        firstnameField.addBorder()
        lastnameField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        lastnameField.roundCorners()
        lastnameField.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstnameField.text = userManager.user?.firstName
        lastnameField.text = userManager.user?.lastName
    }
    
    private func validate() -> Bool {
        if !Validator.validate(string: firstnameField.text ?? "", validation: .isAProperName) || !Validator.validate(string: lastnameField.text ?? "", validation: .isAProperName) {
            let ac = UIAlertController(title: "Please enter a proper name", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
            return false
        }
        
        return true
    }
    
    @IBAction func savePress(_ sender: UIBarButtonItem) {
        if validate() {
            var updateForm = UpdateUserParams()
            updateForm.firstName = firstnameField.text ?? ""
            updateForm.lastName = lastnameField.text ?? ""
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension EditNameViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstnameField {
            // next action
            lastnameField.becomeFirstResponder()
        } else if textField == lastnameField {
            // next action
            lastnameField.resignFirstResponder()
        }
        
        return true
    }
}
