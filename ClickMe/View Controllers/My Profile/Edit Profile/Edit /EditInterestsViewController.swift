//
//  EditInterestsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-21.
//

import UIKit
import WSTagsField

class EditInterestsViewController: BaseScrollingViewController {

    @IBOutlet weak var tagsView: UIView!
    private let tagsField = WSTagsField()
    
    override func setup() {
        super.setup()
        
        tagsView.addBorder()
        tagsField.frame = tagsView.bounds
        tagsView.addSubview(tagsField)
        
        tagsField.cornerRadius = 8.0
        tagsField.spaceBetweenLines = 20
        tagsField.spaceBetweenTags = 5
        tagsField.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        tagsField.textField.returnKeyType = .done
        tagsField.textField.backgroundColor = ThemeManager.shared.themeData!.textFieldBackground.hexColor
        tagsField.textField.tintColor = ThemeManager.shared.themeData!.textLabel.hexColor
        
        tagsField.selectedColor = themeManager.themeData!.indigo.hexColor
        tagsField.selectedTextColor = themeManager.themeData!.whiteBackground.hexColor
        tagsField.textColor = themeManager.themeData!.textLabel.hexColor
        tagsField.tintColor = themeManager.themeData!.whiteBackground.hexColor
        tagsField.font = UIFont.systemFont(ofSize: 15.0)
        tagsField.delimiter = ""
        tagsField.placeholder = "Enter a tag"
        tagsField.backgroundColor = .clear
        tagsField.placeholderColor = themeManager.themeData!.darkLabel.hexColor
        tagsField.placeholderAlwaysVisible = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for interest in userManager.user?.interests ?? [] {
            tagsField.addTag(interest)
        }
    }

    @IBAction func savePress(_ sender: Any) {
        var updateForm = UpdateUserParams()
        updateForm.interests = []
        for tag in tagsField.tags {
            updateForm.interests?.append(tag.text)
        }
        userManager.updateUser(params: updateForm) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
