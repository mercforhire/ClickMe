//
//  LoginInitialViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-15.
//

import UIKit

class LoginInitialViewController: BaseViewController {
    @IBOutlet weak var newUserButton: UIButton!
    @IBOutlet weak var oldUserButton: UIButton!
    
    override func setup() {
        super.setup()
        
        navigationController?.viewControllers = [self]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userManager.isLoggedIn() {
            print("is loggined in")
            loginUser()
        } else {
            print("is not loggined in")
        }
    }
    
    private func loginUser() {
        FullScreenSpinner().show()
        userManager.fetchUser { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            if success {
                self.proceedPassLogin()
            } else {
                self.userManager.logOut()
            }
        }
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
            NotificationCenter.default.post(name: Notifications.LoginFinished, object: nil, userInfo: nil)
        } else {
            userManager.setupManager.goToAppropriateSetupView(vc: self)
        }
    }

    @IBAction func termsPress(_ sender: Any) {
        openURLInBrowser(url: URL(string: "https://www.cpclickme.com/terms.html")!)
    }
    
    @IBAction func privacyPress(_ sender: Any) {
        openURLInBrowser(url: URL(string: "https://www.cpclickme.com/privacy.html")!)
    }
}
