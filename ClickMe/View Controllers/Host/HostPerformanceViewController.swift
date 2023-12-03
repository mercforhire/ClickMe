//
//  HostPerformanceViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit

class HostPerformanceViewController: BaseViewController {
    
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var container4: UIView!
    @IBOutlet weak var container5: UIView!
    @IBOutlet weak var container6: UIView!
    @IBOutlet weak var container7: UIView!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func setup() {
        super.setup()
        
        container1.roundCorners(style: .large)
        container2.roundCorners(style: .large)
        container3.roundCorners()
        container4.roundCorners()
        container5.roundCorners()
        container6.roundCorners()
        container7.roundCorners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        monthLabel.text = ""
        totalLabel.text = ""
        hoursLabel.text = ""
        reviewsLabel.text = ""
        ratingLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReviewsRootViewController {
            vc.userId = userManager.user?.identifier
            vc.userFullName = userManager.user?.fullName
        }
    }
}
