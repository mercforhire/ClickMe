//
//  FSImageAndLabelViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-24.
//

import UIKit

class FSImageAndLabelViewController: UIViewController {
    var backColor: UIColor = ThemeManager.shared.themeData!.defaultBackground.hexColor
    var image: UIImage!
    var labelText: String!
    var textColor: UIColor = ThemeManager.shared.themeData!.indigo.hexColor
    var font: UIFont?
    var tapAction: Action!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    static func createViewController(image: UIImage,
                                     labelText: String,
                                     font: UIFont? = nil,
                                     tapAction: @escaping Action) -> FSImageAndLabelViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Generic", viewControllerId: "FSImageAndLabelViewController") as! FSImageAndLabelViewController
        vc.image = image
        vc.labelText = labelText
        vc.font = font
        vc.tapAction = tapAction
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = backColor
        label.textColor = textColor
        imageView.image = image
        label.text = labelText
        label.font = font ?? label.font
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        tapAction()
    }
}
