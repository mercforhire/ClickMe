//
//  DonateViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-24.
//

import UIKit

protocol DonateViewControllerDelegate: class {
    func donatedAmount(amount: Int)
}

class DonateViewController: BaseViewController {
    var donateTo: ListUser!
    
    enum DonationChoices: Int {
        case amount1
        case amount2
        case amount3
        case amount4
        case custom
        
        func getAmount() -> Int {
            switch self {
            case .amount1:
                return 100
            case .amount2:
                return 200
            case .amount3:
                return 500
            case .amount4:
                return 1000
            case .custom:
               return 0
            }
        }
    }
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var amount1Button: UIView!
    @IBOutlet weak var amount2Button: UIView!
    @IBOutlet weak var amount3Button: UIView!
    @IBOutlet weak var amount4Button: UIView!
    @IBOutlet weak var customButton: UIView!
    
    @IBOutlet weak var amount1Label: ThemeBlackTextLabel!
    @IBOutlet weak var amount2Label: ThemeBlackTextLabel!
    @IBOutlet weak var amount3Label: ThemeBlackTextLabel!
    @IBOutlet weak var amount4Label: ThemeBlackTextLabel!
    @IBOutlet weak var customAmountLabel: ThemeBlackTextLabel!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var thankYouView: UIView!
    
    weak var delegate: DonateViewControllerDelegate?
    
    var choice: DonationChoices? {
        didSet {
            switch choice {
            case .amount1:
                amount1Button.highlight()
                amount2Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount3Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount4Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                customButton.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                         text: themeManager.themeData!.textLabel.hexColor)
            case .amount2:
                amount1Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount2Button.highlight()
                amount3Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount4Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                customButton.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                         text: themeManager.themeData!.textLabel.hexColor)
            case .amount3:
                amount1Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount2Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount3Button.highlight()
                amount4Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                customButton.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                         text: themeManager.themeData!.textLabel.hexColor)
            case .amount4:
                amount1Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount2Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount3Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount4Button.highlight()
                customButton.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                         text: themeManager.themeData!.textLabel.hexColor)
            case .custom:
                amount1Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount2Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount3Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount4Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                customButton.highlight()
            case .none:
                amount1Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount2Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount3Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                amount4Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                          text: themeManager.themeData!.textLabel.hexColor)
                customButton.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                         text: themeManager.themeData!.textLabel.hexColor)
            }
            
            switch choice {
            case .amount1, .amount2, .amount3, .amount4:
                customAmount = nil
                submitButton.isEnabled = true
            case .none:
                customAmount = nil
                submitButton.isEnabled = false
            default:
                submitButton.isEnabled = false
            }
        }
    }
    var customAmount: Int? {
        didSet {
            if let amount = customAmount, amount > 0 {
                submitButton.isEnabled = true
                customAmountLabel.text = "\(amount)"
            } else {
                submitButton.isEnabled = false
                customAmountLabel.text = "+"
            }
        }
    }
    
    static func createViewController(donateTo: ListUser, delegate: DonateViewControllerDelegate? = nil) -> UINavigationController {
        let vc = StoryboardManager.loadViewController(storyboard: "Calling", viewControllerId: "DonateViewController") as! DonateViewController
        vc.donateTo = donateTo
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        return nc
    }
    
    override func setup() {
        super.setup()
        
        amount1Button.addBorder()
        amount2Button.addBorder()
        amount3Button.addBorder()
        amount4Button.addBorder()
        
        amount1Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                  text: themeManager.themeData!.textLabel.hexColor)
        amount2Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                  text: themeManager.themeData!.textLabel.hexColor)
        amount3Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                  text: themeManager.themeData!.textLabel.hexColor)
        amount4Button.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                  text: themeManager.themeData!.textLabel.hexColor)
        customButton.unhighlight(back: themeManager.themeData!.defaultBackground.hexColor,
                                 text: themeManager.themeData!.textLabel.hexColor)
        
        self.amount1Label.text = "\(DonationChoices.amount1.getAmount())"
        self.amount2Label.text = "\(DonationChoices.amount2.getAmount())"
        self.amount3Label.text = "\(DonationChoices.amount3.getAmount())"
        self.amount4Label.text = "\(DonationChoices.amount4.getAmount())"
        
        avatar.roundCorners()
        customButton.addBorder()
        submitButton.roundCorners()
        
        thankYouView.alpha = 0.0
        thankYouView.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.theme == .light ? themeManager.themeData!.indigo.hexColor : themeManager.themeData!.defaultBackground.hexColor
        
        thankYouView.backgroundColor = themeManager.theme == .light ? themeManager.themeData!.indigo.hexColor : themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        userManager.fetchUser { [weak self] success in
            if success {
                self?.refreshView()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    private func refreshView() {
        if let urlString = donateTo.avatarURL, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = donateTo.defaultAvatar
        }
        nameLabel.text = donateTo.fullName
        jobLabel.text = donateTo.jobTitle
        walletBalanceLabel.text = "\(userManager.user?.wallet?.preferredAccount.name().capitalizingFirstLetter() ?? "") balance: \(userManager.user?.wallet?.preferredAccountAmount ?? 0)"
    }
    
    @IBAction func donationChoice1Tapped(_ sender: UITapGestureRecognizer) {
        self.choice = .amount1
    }
    
    @IBAction func donationChoice2Tapped(_ sender: UITapGestureRecognizer) {
        self.choice = .amount2
    }
    
    @IBAction func donationChoice3Tapped(_ sender: UITapGestureRecognizer) {
        self.choice = .amount3
    }
    
    @IBAction func donationChoice4Tapped(_ sender: UITapGestureRecognizer) {
        self.choice = .amount4
    }
    
    @IBAction func donationChoice5Tapped(_ sender: UITapGestureRecognizer) {
        openEnterAmountDialog()
    }
    
    @IBAction func infoPressed(_ sender: Any) {
        showErrorDialog(error: "Please note that 5% of every transaction is taken as a transaction fee.")
    }
    
    @IBAction private func submitPressed(_ sender: Any) {
        var amount: Int = 0
        switch choice {
        case .amount1, .amount2, .amount3, .amount4:
            amount = choice!.getAmount()
        case .custom:
            amount = customAmount ?? 100
        default:
            print("DonateViewController error")
            return
        }
        
        guard amount <= userManager.user?.wallet?.preferredAccountAmount ?? 0 else {
            showErrorDialog(error: "Must be less than or equal to wallet's preferred account balance")
            return
        }
        
        FullScreenSpinner().show()
        api.tipUser(userId: donateTo.identifier, amount: amount) { [weak self] result in
            guard let self = self else { return }
            FullScreenSpinner().hide()
            
            switch result {
            case .success:
                self.delegate?.donatedAmount(amount: amount)
                self.showThankyouView()
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func openEnterAmountDialog() {
        let ac = UIAlertController(title: "Enter amount", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.keyboardType = .numberPad
            textfield.maxLength = 3
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            if let answer = ac.textFields![0].text {
                self.choice = .custom
                if Int(answer) ?? 0 > MinimalRedeem {
                    self.customAmount = Int(answer)
                } else {
                    showErrorDialog(error: "Custom amount must be > \(MinimalRedeem)")
                    return
                }
            } else {
                self.customAmount = nil
            }
        }
        ac.addAction(submitAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func showThankyouView() {
        thankYouView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.thankYouView.alpha = 1.0
        }
    }
}
