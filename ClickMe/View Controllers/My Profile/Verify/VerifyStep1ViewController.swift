//
//  VerifyStep1ViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-27.
//

import UIKit

class VerifyStep1ViewController: BaseViewController {
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bodyLabel.text = Lorem.paragraph
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        let vc = StoryboardManager.loadViewController(storyboard: "Verify", viewControllerId: "VerifyStep2ViewController") as! VerifyCameraViewController
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension VerifyStep1ViewController: VerifyCameraViewControllerDelegate {
    func verifyComplete() {
        performSegue(withIdentifier: "goToVerificationComplete", sender: self)
    }
}
