//
//  SetupJobEducationViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import UIKit

class SetupJobEducationViewController: BaseScrollingViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var schoolField: PaddedTextField!
    @IBOutlet weak var programField: PaddedTextField!
    @IBOutlet weak var companyField: PaddedTextField!
    @IBOutlet weak var titleField: PaddedTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func setup() {
        super.setup()
        
        schoolField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        programField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        companyField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        titleField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        schoolField.roundCorners()
        schoolField.addBorder()
        
        programField.roundCorners()
        programField.addBorder()
        
        companyField.roundCorners()
        companyField.addBorder()
        
        titleField.roundCorners()
        titleField.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        contentView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        schoolField.text = userManager.user?.school
        programField.text = userManager.user?.degree
        companyField.text = userManager.user?.company
        titleField.text = userManager.user?.jobTitle
    }
    
    @IBAction func skipPressed(_ sender: Any) {
        userManager.setupManager.skipped(screen: .JobEducation)
    }
    
    @IBAction func nextPress(_ sender: Any) {
        if validate() {
            var updateForm = UpdateUserParams()
            updateForm.school = schoolField.text ?? ""
            updateForm.degree = programField.text ?? ""
            updateForm.company = companyField.text ?? ""
            updateForm.jobTitle = titleField.text ?? ""
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                self.goToNextScreen()
            }
        }
    }
    
    private func goToNextScreen() {
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
    
    private func validate() -> Bool {
        if (schoolField.text ?? "").isEmpty {
            showErrorDialog(error: "Please enter school name")
            return false
        } else if (programField.text ?? "").isEmpty {
            showErrorDialog(error: "Please enter program name")
            return false
        } else if (companyField.text ?? "").isEmpty {
            showErrorDialog(error: "Please fill company name")
            return false
        } else if (titleField.text ?? "").isEmpty {
            showErrorDialog(error: "Please fill job title")
            return false
        }
        
        return true
    }
}

extension SetupJobEducationViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == schoolField {
            // next action
            schoolField.becomeFirstResponder()
        } else if textField == programField {
            // return action
            companyField.becomeFirstResponder()
        } else if textField == companyField {
            // return action
            titleField.becomeFirstResponder()
        } else if textField == companyField {
            // return action
            companyField.resignFirstResponder()
        }
        
        return true
    }
}
