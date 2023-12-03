//
//  EditEducationViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit

class EditEducationViewController: BaseViewController {
    @IBOutlet weak var schoolField: PaddedTextField!
    @IBOutlet weak var degreeField: PaddedTextField!
    
    override func setup() {
        super.setup()
        
        schoolField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        schoolField.roundCorners()
        schoolField.addBorder()
        
        degreeField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        degreeField.roundCorners()
        degreeField.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        schoolField.text = userManager.user?.school
        degreeField.text = userManager.user?.degree
    }
    
    private func validate() -> Bool {
        if let school = schoolField.text, !school.isEmpty,
           let degree = degreeField.text, !degree.isEmpty {
            return true
        } else {
            let ac = UIAlertController(title: "Please make fill both fields", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
            return false
        }
    }

    @IBAction func savePress(_ sender: Any) {
        if validate(), let school = schoolField.text, let degree = degreeField.text {
            var updateForm = UpdateUserParams()
            updateForm.school = school
            updateForm.degree = degree
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension EditEducationViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == schoolField {
            // next action
            _ = degreeField.becomeFirstResponder()
        } else if textField == degreeField {
            // next action
            textField.resignFirstResponder()
        }
        
        return true
    }
}
