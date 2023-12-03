//
//  EditBirthdayViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit
import MonthYearPicker

class EditBirthdayViewController: BaseViewController {
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var publicButton: UIButton!
    
    private var birthday: Date? {
        didSet {
            if let birthday = birthday {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-yyyy"
                let dateString = dateFormatter.string(from: birthday)
                birthdayField.text = dateString
            }
        }
    }
    
    private var isBirthdayPublic: Bool = true {
        didSet {
            if isBirthdayPublic {
                privateButton.unhighlightButton()
                publicButton.highlightButton()
            } else {
                privateButton.highlightButton()
                publicButton.unhighlightButton()
            }
            
            _ = validate()
        }
    }
    
    override func setup() {
        super.setup()
        
        birthdayField.roundCorners()
        birthdayField.addBorder()
        
        privateButton.addBorder()
        publicButton.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        birthday = userManager.user?.birthday
        birthdayField.monthYearPicker(date: birthday ?? Date().getPastOrFutureDate(year: -20), cancelAction: #selector(cancelAction), doneAction: #selector(doneAction))
        isBirthdayPublic = userManager.user?.isBirthdayPublic ?? true
    }
    
    @IBAction func privatePress(_ sender: Any) {
        isBirthdayPublic = false
    }
    
    @IBAction func publicPress(_ sender: Any) {
        isBirthdayPublic = true
    }
    
    private func validate() -> Bool {
        if let birthday = birthday {
            if birthday.ageToday() < 18 {
                let ac = UIAlertController(title: "Must be at least 18 years old", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .default)
                ac.addAction(cancelAction)
                present(ac, animated: true)
                return false
            }
        } else {
            let ac = UIAlertController(title: "Please enter birthday", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
            return false
        }
        
        return true
    }
    
    @IBAction func savePress(_ sender: Any) {
        if validate(), let birthday = birthday {
            var updateForm = UpdateUserParams()
            updateForm.birthday = birthday
            updateForm.isBirthdayPublic = isBirthdayPublic
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func cancelAction() {
        birthdayField.resignFirstResponder()
    }
    
    @objc func doneAction() {
        if let datePickerView = birthdayField.inputView as? MonthYearPickerView {
            birthday = datePickerView.date.getPastOrFutureDate(day: 15)
            birthdayField.resignFirstResponder()
        }
    }
}
