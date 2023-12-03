//
//  RedeemViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-26.
//

import UIKit

class RedeemViewController: BaseViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var earnedAmount: UILabel!
    
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var coinsField: PaddedTextField!
    @IBOutlet weak var coinsFieldErrorLabel: UILabel!
    @IBOutlet weak var dollarAmountField: PaddedTextField!
    
    @IBOutlet weak var container4: UIView!
    @IBOutlet weak var emailField: ThemePaddedTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var amountAvailable: Int = 0
    
    var coinsFieldErrorString: String? {
        didSet {
            if let coinsFieldErrorString = coinsFieldErrorString, !coinsFieldErrorString.isEmpty {
                coinsFieldErrorLabel.text = coinsFieldErrorString
            } else {
                coinsFieldErrorLabel.text = ""
            }
        }
    }
    
    var emailErrorString: String? {
        didSet {
            if let emailErrorString = emailErrorString, !emailErrorString.isEmpty {
                emailErrorLabel.text = emailErrorString
            } else {
                emailErrorLabel.text = ""
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        container.roundCorners(style: .medium)
        container3.roundCorners(style: .medium)
        container4.roundCorners(style: .medium)
        
        coinsField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        coinsField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        dollarAmountField.text = ""
        coinsFieldErrorLabel.text = ""
        
        emailField.roundCorners()
        emailField.addBorder()
        emailField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        emailErrorLabel.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        amountAvailable = userManager.user?.wallet?.earnedCoins ?? 0
        earnedAmount.text = "\(amountAvailable)"
        
    }

    @IBAction func confirmPress(_ sender: Any) {
        if validate(),
           let amount = coinsField.text?.int,
           let email = emailField.text, !email.isEmpty {
            FullScreenSpinner().show()
            api.cashOut(email: email,
                        emailMessage: "ClickMe coins cashout",
                        emailSubject: "ClickMe coins cashout",
                        coins: amount) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else if error.responseCode == 415 {
                        showErrorDialog(error: "Sorry, the cash out amount has reached for the day.($500)")
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                }
            }
        }
    }
    
    private func validate() -> Bool {
        guard let amount = coinsField.text?.int else {
            coinsFieldErrorString = "* Invalid entry"
            return false
        }
        
        if amount > amountAvailable {
            coinsFieldErrorString = "* More than what you have"
            return false
        }
        
        if amount < MinimalRedeem {
            coinsFieldErrorString = "* Minimal redemption \(MinimalRedeem) coins"
            return false
        }
        
        coinsFieldErrorString = ""
        
        if (emailField.text ?? "").isEmpty {
            emailErrorString = "* Email is empty"
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            emailErrorString = "* Invalid email"
            return false
        }
        
        emailErrorString = ""
        
        return true
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == coinsField {
            if let amount = textfield.text?.int {
                textfield.text = "\(amount)"
                dollarAmountField.text = "\(String(format: "%.2f", Double(amount) / 100.0))"
            } else {
                textfield.text = ""
                dollarAmountField.text = ""
            }
        }
    }
}

extension RedeemViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
