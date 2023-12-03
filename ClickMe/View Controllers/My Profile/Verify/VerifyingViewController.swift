//
//  VerifyingViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit

class VerifyingViewController: UIViewController {
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bodyLabel.text = Lorem.paragraph
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

    @IBAction func okayButton(_ sender: Any) {
        _ = navigationController?.popToViewControllerOfClass(kind: SettingsViewController.self)
    }
    
}
