//
//  EditLocationViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-20.
//

import UIKit

class EditLocationViewController: BaseViewController {
    @IBOutlet weak var hometownField: PaddedTextField!
    @IBOutlet weak var locationField: PaddedTextField!
    
    var hometown: Location? {
        didSet {
            if let location = hometown {
                hometownField.text = location.locationString
            }
        }
    }
    var hometownChanged: Bool = false
    
    var liveAt: Location? {
        didSet {
            if let location = liveAt {
                locationField.text = location.locationString
            }
        }
    }
    var liveAtChanged: Bool = false
    
    override func setup() {
        super.setup()
        
        hometownField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        hometownField.roundCorners()
        hometownField.addBorder()
        
        locationField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        locationField.roundCorners()
        locationField.addBorder()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hometown = userManager.user?.hometown
        liveAt = userManager.user?.liveAt
    }
    
    @IBAction func hometownPress(_ sender: Any) {
        goToLocationPicker(hometown: true)
    }
    
    @IBAction func locationPress(_ sender: Any) {
        goToLocationPicker(hometown: false)
    }

    @IBAction func savePress(_ sender: Any) {
        var updateForm = UpdateUserParams()
        
        if hometownChanged {
            updateForm.hometown = hometown
        }
        
        if liveAtChanged {
            updateForm.liveAt = liveAt
        }
        
        userManager.updateUser(params: updateForm) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func goToLocationPicker(hometown: Bool) {
        let vc = StoryboardManager.loadViewController(storyboard: "MyProfile", viewControllerId: "LocationPickerViewController") as! BaseLocationPickerViewController
        vc.showCurrentLocationButton = true
        vc.useCurrentLocationAsHint = true
        vc.selectCurrentLocationInitially = true
        vc.completion = { [weak self] location in
            guard let self = self, let location = location else { return }
            
            if hometown {
                self.hometown = Location(placemark: location.placemark)
                self.hometownChanged = true
            } else {
                self.liveAt = Location(placemark: location.placemark)
                self.liveAtChanged = true
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
