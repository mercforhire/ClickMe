//
//  WalletViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-26.
//

import UIKit

class WalletViewController: BaseViewController {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var earnedLabel: UILabel!
    @IBOutlet weak var boughtLabel: UILabel!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshWallet()
    }
    
    func refreshWallet() {
        userManager.fetchUser { [weak self] success in
            if success {
                self?.refreshView()
            }
        }
    }
    
    func refreshView() {
        guard let wallet = userManager.user?.wallet else { return }
        
        totalLabel.text = "\(wallet.total)"
        earnedLabel.text = "\(WalletType.earned.rawValue.capitalizingFirstLetter()) \(wallet.earnedCoins)"
        boughtLabel.text = "\(WalletType.purchased.rawValue.capitalizingFirstLetter()) \(wallet.purchasedCoins)"
    }
    
    @IBAction func earnWithdrawPressed(_ sender: Any) {
        guard let wallet = userManager.user?.wallet else { return }
        
        if wallet.earnedCoins > MinimalRedeem {
            performSegue(withIdentifier: "goToRedeem", sender: self)
        } else {
            let ac = UIAlertController(title: "Minimal redemption \(MinimalRedeem) coins.", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
        }
    }
    
    @IBAction func rechargePressed(_ sender: Any) {
        performSegue(withIdentifier: "goToRecharge", sender: self)
    }
}
