//
//  RechargeSuccessViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-26.
//

import UIKit

class RechargeSuccessViewController: UIViewController {
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func donePress(_ sender: Any) {
        if navigationController?.popToViewControllerOfClass(kind: WalletViewController.self) == true {
            return
        }
        if navigationController?.popToViewControllerOfClass(kind: TopicDetailViewController.self) == true {
            return
        }
    }

}
