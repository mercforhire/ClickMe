//
//  ComingSoonViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-09-03.
//

import UIKit

class ComingSoonViewController: BaseViewController {

    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
