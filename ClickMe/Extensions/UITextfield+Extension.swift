//
//  UITextfield+Extension.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-10.
//

import Foundation
import UIKit
import MonthYearPicker

private var maxLengths = [UITextField: Int]()
private var minLengths = [UITextField: Int]()

extension UITextField {
    
    //MARK:- Maximum length
    @IBInspectable var maxLength: Int {
        get {
            guard let length = maxLengths[self] else {
                return 100
            }
            return length
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(fixMax), for: .editingChanged)
        }
    }
    @objc func fixMax(textField: UITextField) {
        let text = textField.text
        textField.text = text?.safelyLimitedTo(length: maxLength)
    }
    
    //MARk:- Minimum length
    @IBInspectable var minLegth: Int {
        get {
            guard let l = minLengths[self] else {
                return 0
            }
            return l
        }
        set {
            minLengths[self] = newValue
            addTarget(self, action: #selector(fixMin), for: .editingChanged)
        }
    }
    @objc func fixMin(textField: UITextField) {
        let text = textField.text
        textField.text = text?.safelyLimitedFrom(length: minLegth)
    }
}

extension String {
    func safelyLimitedTo(length n: Int) -> String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    
    func safelyLimitedFrom(length n: Int) -> String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}

extension UITextField {
    func monthYearPicker(date: Date, cancelAction: Selector, doneAction: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let picker = MonthYearPickerView(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: screenWidth,
                                                       height: 200))
        picker.minimumDate = Date().getPastOrFutureDate(years: -100)
        picker.date = date
        picker.maximumDate = Date()
        inputView = picker
        
        func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
            let buttonTarget = style == .flexibleSpace ? nil : target
            let action: Selector? = {
                switch style {
                case .cancel:
                    return cancelAction
                case .done:
                    return doneAction
                default:
                    return nil
                }
            }()
            
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                                target: buttonTarget,
                                                action: action)
            return barButtonItem
        }
        
        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: screenWidth,
                                              height: 44))
        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        inputAccessoryView = toolBar
    }
    
    func datePicker<T>(target: T,
                       defaultDate: Date,
                       doneAction: Selector,
                       cancelAction: Selector,
                       datePickerMode: UIDatePicker.Mode = .date) {
        let screenWidth = UIScreen.main.bounds.width
        
        func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
            let buttonTarget = style == .flexibleSpace ? nil : target
            let action: Selector? = {
                switch style {
                case .cancel:
                    return cancelAction
                case .done:
                    return doneAction
                default:
                    return nil
                }
            }()
            
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                                target: buttonTarget,
                                                action: action)
            
            return barButtonItem
        }
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: screenWidth,
                                                    height: 100))
        datePicker.datePickerMode = datePickerMode
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = defaultDate
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: screenWidth,
                                              height: 44))
        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        inputAccessoryView = toolBar
    }
    
    func addLeftInset() {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
        leftViewMode = .always
    }
}
