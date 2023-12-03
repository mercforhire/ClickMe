//
//  BaseLocationPickerViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-29.
//

import UIKit
import LocationPicker

class BaseLocationPickerViewController: LocationPickerViewController {
    var api: ClickAPI {
        return ClickAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = themeManager.themeData!.navBarTheme.backgroundColor.hexColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.themeData!.navBarTheme.textColor.hexColor]
    }

    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
