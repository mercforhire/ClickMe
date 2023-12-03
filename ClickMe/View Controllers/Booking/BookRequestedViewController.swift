//
//  BookRequestedViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-01.
//

import UIKit

class BookRequestedViewController: BaseViewController {

    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

    @IBAction func donePress(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
}
