//
//  WalletChooseViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-07-22.
//

import UIKit

class WalletChooseViewController: BaseViewController {
    
    @IBOutlet weak var selection1Outline: UIView!
    @IBOutlet weak var selection1Inner: UIView!
    @IBOutlet weak var selection2Outline: UIView!
    @IBOutlet weak var selection2Inner: UIView!

    var selection: WalletType? {
        didSet {
            switch selection {
            case .purchased:
                selection1Inner.backgroundColor = themeManager.themeData!.indigo.hexColor
                selection2Inner.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
            case .earned:
                selection1Inner.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
                selection2Inner.backgroundColor = themeManager.themeData!.indigo.hexColor
            default:
                selection1Inner.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
                selection2Inner.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        selection1Outline.roundCorners(style: .completely)
        selection1Inner.roundCorners(style: .completely)
        selection2Outline.roundCorners(style: .completely)
        selection2Inner.roundCorners(style: .completely)
        
        selection1Inner.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        selection2Inner.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selection = userManager.user?.wallet?.preferredAccount
    }
    
    @IBAction func purchasedCoinsPress(_ sender: Any) {
        
    }
    
    @IBAction func earnedCoinsPress(_ sender: Any) {
        
    }
}
