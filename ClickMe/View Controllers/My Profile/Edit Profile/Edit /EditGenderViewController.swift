//
//  EditGenderViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit

class EditGenderViewController: BaseViewController {
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var notToSayButton: UIButton!
    
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
    
    override func setup() {
        super.setup()
        
        maleButton.addBorder()
        femaleButton.addBorder()
        otherButton.addBorder()
        notToSayButton.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gender = userManager.user?.gender ?? .unknown
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
    
    @IBAction func notToSay(_ sender: Any) {
        gender = .unknown
    }
    
    @IBAction func savePressed(_ sender: Any) {
        var updateForm = UpdateUserParams()
        updateForm.gender = gender
        userManager.updateUser(params: updateForm) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
