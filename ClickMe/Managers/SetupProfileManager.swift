//
//  SetupProfileManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-22.
//

import Foundation
import UIKit

enum SetupProfileScreens: String {
    case Name = "SetupNameViewController"
    case Photo = "SetupPhotoViewController"
    case GenderBirthday = "SetupGenderBirthdayViewController"
    case Languages = "SetupLanguagesViewController"
    case Field = "SetupFieldViewController"
    case JobEducation = "SetupJobEducationViewController"
    case AboutMe = "SetupAboutMeViewController"
}

class SetupProfileManager {
    var userManager: UserManager
    var skipped: Set<SetupProfileScreens> = []
    
    init(userManager: UserManager) {
        self.userManager = userManager
    }
    
    func skipped(screen: SetupProfileScreens) {
        skipped.insert(screen)
    }
    
    func reset() {
        skipped = []
    }
    
    func isProfileFullySetup() -> Bool {
        guard let user = userManager.user else { return false }
        
        // check for Name, Photo, GenderBirthday, Languages, Field
        
        if user.firstName.isEmpty || user.lastName.isEmpty {
            return false
        }
        
        if user.birthday == nil {
            return false
        }
        
        if user.languages == nil || user.languages!.isEmpty {
            return false
        }
        
        if user.field == nil {
            return false
        }
        
        return true
    }
    
    
    func goToAppropriateSetupView(vc: UIViewController) {
        guard let user = userManager.user else { return }
        
        // check for Name, Photo, GenderBirthday, Languages, Field
        
        if user.firstName.isEmpty || user.lastName.isEmpty {
            let nextVC = StoryboardManager.loadViewController(storyboard: "SetupProfile", viewControllerId: SetupProfileScreens.Name.rawValue)!
            
            vc.navigationController?.pushViewController(nextVC, animated: true)
        } else if !skipped.contains(.Photo), user.photos == nil || user.photos!.isEmpty {
            let nextVC = StoryboardManager.loadViewController(storyboard: "SetupProfile", viewControllerId: SetupProfileScreens.Photo.rawValue)!
            
            vc.navigationController?.pushViewController(nextVC, animated: true)
        } else if user.birthday == nil {
            let nextVC = StoryboardManager.loadViewController(storyboard: "SetupProfile", viewControllerId: SetupProfileScreens.GenderBirthday.rawValue)!
            
            vc.navigationController?.pushViewController(nextVC, animated: true)
        } else if user.languages == nil || user.languages!.isEmpty {
            let nextVC = StoryboardManager.loadViewController(storyboard: "SetupProfile", viewControllerId: SetupProfileScreens.Languages.rawValue)!
            
            vc.navigationController?.pushViewController(nextVC, animated: true)
        } else if user.field == .unknown {
            let nextVC = StoryboardManager.loadViewController(storyboard: "SetupProfile", viewControllerId: SetupProfileScreens.Field.rawValue)!
            
            vc.navigationController?.pushViewController(nextVC, animated: true)
        } else if !skipped.contains(.JobEducation), user.jobTitle.isEmpty || user.company.isEmpty || user.school.isEmpty || user.degree.isEmpty {
            let nextVC = StoryboardManager.loadViewController(storyboard: "SetupProfile", viewControllerId: SetupProfileScreens.JobEducation.rawValue)!
            
            vc.navigationController?.pushViewController(nextVC, animated: true)
        } else if !skipped.contains(.AboutMe), user.aboutMe.isEmpty {
            let nextVC = StoryboardManager.loadViewController(storyboard: "SetupProfile", viewControllerId: SetupProfileScreens.AboutMe.rawValue)!
            
            vc.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            goToWelcome(vc: vc)
        }
    }
    
    
    private func goToWelcome(vc: UIViewController) {
        let finalVC: FSImageAndLabelViewController = FSImageAndLabelViewController.createViewController(image: UIImage(named: "Cheer")!, labelText: "Welcome to CP CLICKME") { [weak self] in
            vc.navigationController?.dismiss(animated: true, completion: { [weak self] in
                self?.goToMain(vc: vc)
            })
        }
        finalVC.font = UIFont.systemFont(ofSize: 34.0, weight: .bold)
        let nc = UINavigationController(rootViewController: finalVC)
        nc.modalPresentationStyle = .fullScreen
        vc.present(nc, animated: true, completion: nil)
    }
    
    private func goToMain(vc: UIViewController) {
        guard let mainVc = StoryboardManager.loadViewController(storyboard: "Main", viewControllerId: "GuestViewController") else { return }
        
        vc.navigationController?.pushViewController(mainVc, animated: true)
    }
}
