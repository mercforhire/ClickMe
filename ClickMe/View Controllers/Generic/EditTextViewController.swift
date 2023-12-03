//
//  EditTextViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-22.
//

import UIKit

class EditTextViewController: BaseViewController {
    var text: String = ""
    var maxCharCount: Int?
    
    @IBOutlet weak var editTextView: UITextView!
    @IBOutlet weak var charCountLabel: ThemeDarkTextLabel!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    var completion: ((String) -> Void)?
    
    static func createViewController(title: String,
                                     initialText: String,
                                     maxCharCount: Int? = nil,
                                     completion: @escaping (String) -> Void) -> UINavigationController {
        let vc = StoryboardManager.loadViewController(storyboard: "Generic", viewControllerId: "EditTextViewController") as! EditTextViewController
        vc.title = title
        vc.text = initialText
        vc.maxCharCount = maxCharCount
        vc.completion = completion
        
        let nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.barTintColor = ThemeManager.shared.themeData!.navBarTheme.backgroundColor.hexColor
        nc.navigationBar.titleTextAttributes = [.foregroundColor: ThemeManager.shared.themeData!.navBarTheme.textColor.hexColor]
        return nc
    }
    
    override func setup() {
        super.setup()
        
        editTextView.roundCorners()
        editTextView.addInset()
        charCountLabel.isHidden = maxCharCount == nil
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        editTextView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        editTextView.textColor = themeManager.themeData!.textLabel.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editTextView.text = text
        charCountLabel.text = "\(editTextView.text.count)/\(maxCharCount ?? 0)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction private func cancelPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func savePress(_ sender: Any) {
        completion?(editTextView.text)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Keyboard show and hide methods
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomMargin.constant = 20.0 + keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(_: Notification) {
        bottomMargin.constant = 20.0
    }
}

extension EditTextViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let charCountLimit = maxCharCount else { return true }
        
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under 150 characters
        return updatedText.count <= charCountLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charCountLabel.text = "\(editTextView.text.count)/\(maxCharCount ?? 0)"
    }
}
