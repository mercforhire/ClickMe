//
//  SetupGenderBirthdayViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import UIKit
import MonthYearPicker

class SetupGenderBirthdayViewController: BaseViewController {    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var notToSayButton: UIButton!
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private var gender: GenderChoice = .unknown {
        didSet {
            switch gender {
            case .male:
                maleButton.highlightButton()
                femaleButton.unhighlightButton()
                otherButton.unhighlightButton()
                notToSayButton.unhighlightButton()
            case .female:
                maleButton.unhighlightButton()
                femaleButton.highlightButton()
                otherButton.unhighlightButton()
                notToSayButton.unhighlightButton()
            case .other:
                maleButton.unhighlightButton()
                femaleButton.unhighlightButton()
                otherButton.highlightButton()
                notToSayButton.unhighlightButton()
            default:
                maleButton.unhighlightButton()
                femaleButton.unhighlightButton()
                otherButton.unhighlightButton()
                notToSayButton.highlightButton()
            }
        }
    }
    
    private var birthday: Date? {
        didSet {
            if let birthday = birthday {
                birthdayField.text = DateUtil.convert(input: birthday, outputFormat: .format14)
            }
        }
    }
    
    private var isBirthdayPublic: Bool? {
        didSet {
            switch isBirthdayPublic {
            case false:
                privateButton.highlightButton()
                publicButton.unhighlightButton()
            case true:
                privateButton.unhighlightButton()
                publicButton.highlightButton()
            default:
                privateButton.unhighlightButton()
                publicButton.unhighlightButton()
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        maleButton.addBorder()
        femaleButton.addBorder()
        otherButton.addBorder()
        notToSayButton.addBorder()
        birthdayField.addBorder()
        birthdayField.roundCorners()
        birthdayField.monthYearPicker(date: Date().getPastOrFutureDate(year: -20), cancelAction: #selector(cancelAction), doneAction: #selector(doneAction))
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
        gender = userManager.user?.gender ?? .unknown
        birthday = userManager.user?.birthday
        isBirthdayPublic = userManager.user?.isBirthdayPublic ?? true
    }
    
    @IBAction func malePress(_ sender: Any) {
        gender = .male
    }
    
    @IBAction func femalePress(_ sender: Any) {
        gender = .female
    }
    
    @IBAction func otherPress(_ sender: Any) {
        gender = .other
    }
    
    @IBAction func notToSayPress(_ sender: Any) {
        gender = .unknown
    }
    
    @IBAction func privatePress(_ sender: Any) {
        isBirthdayPublic = false
    }
    
    @IBAction func publicPress(_ sender: Any) {
        isBirthdayPublic = true
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
    
    @IBAction func nextPress(_ sender: Any) {
        if validate() {
            var updateForm = UpdateUserParams()
            updateForm.gender = gender
            updateForm.birthday = birthday
            updateForm.isBirthdayPublic = isBirthdayPublic ?? false
            
            userManager.updateUser(params: updateForm) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    self.goToNextScreen()
                }
            }
        }
    }
    
    private func goToNextScreen() {
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
    
    private func validate() -> Bool {
        if birthday != nil && isBirthdayPublic != nil {
            return true
        } else {
            showErrorDialog(error: "Please enter all information.")
            return false
        }
    }
}
