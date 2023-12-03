//
//  SetupAboutMeViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import UIKit

class SetupAboutMeViewController: BaseScrollingViewController {
    @IBOutlet weak var aboutMeField: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func setup() {
        super.setup()
        
        aboutMeField.addBorder()
        aboutMeField.roundCorners()
        aboutMeField.addInset()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        contentView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        aboutMeField.text = userManager.user?.aboutMe
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if !aboutMeField.text.isEmpty {
            var updateForm = UpdateUserParams()
            updateForm.aboutMe = aboutMeField.text ?? ""
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                self.goToNextScreen()
            }
        } else {
            showErrorDialog(error: "Please fill out About Me")
        }
    }
    
    @IBAction func skipPress(_ sender: Any) {
        userManager.setupManager.skipped(screen: .AboutMe)
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
    
    private func goToNextScreen() {
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
}
