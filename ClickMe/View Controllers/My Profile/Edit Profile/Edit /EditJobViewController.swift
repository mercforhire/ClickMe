//
//  EditJobViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit

class EditJobViewController: BaseViewController {
    @IBOutlet weak var jobField: PaddedTextField!
    @IBOutlet weak var companyField: PaddedTextField!
    
    override func setup() {
        super.setup()
        
        jobField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        jobField.roundCorners()
        jobField.addBorder()
        
        companyField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        companyField.roundCorners()
        companyField.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        jobField.text = userManager.user?.jobTitle
        companyField.text = userManager.user?.company
    }

    private func validate() -> Bool {
        if let job = jobField.text, !job.isEmpty,
           let company = companyField.text, !company.isEmpty {
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
        if validate(), let job = jobField.text, let company = companyField.text {
            var updateForm = UpdateUserParams()
            updateForm.company = company
            updateForm.jobTitle = job
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension EditJobViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == jobField {
            // next action
            _ = companyField.becomeFirstResponder()
        } else if textField == companyField {
            // next action
            textField.resignFirstResponder()
        }
        
        return true
    }
}
