//
//  BaseScrollingViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-23.
//

import UIKit
import Foundation
import ScrollingContentViewController
import SKCountryPicker

class BaseScrollingViewController: ScrollingContentViewController {
    private var observer: NSObjectProtocol?
    
    var api: ClickAPI {
        return ClickAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    @IBOutlet weak var noResultsViewContainer: UIView!
    lazy var errorView = ErrorView.fromNib()! as! ErrorView
    lazy var backgroundView = UIImageView()
    
    var countryPicker: UIPickerView?
    var countries: [Country]?
    var areaCodeFields: [UITextField] = []
    var tutorialManager: TutorialManager?
    open var selectedCountry: Country?
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if noResultsViewContainer != nil {
            noResultsViewContainer.fill(with: errorView)
            noResultsViewContainer.isHidden = true
            errorView.configureUI(style: .noData)
        }
        setup()
        scrollView.backgroundColor = contentView.backgroundColor
        scrollView.subviews[0].backgroundColor = contentView.backgroundColor
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem? = nil) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func coinPressed() {
        let vc = StoryboardManager.loadViewController(storyboard: "Wallet", viewControllerId: "WalletViewController")!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showBackground() {
        backgroundView.image = UIImage(named: "background")
        backgroundView.contentMode = .scaleToFill
        view.fill(with: backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIViewController.topViewController == self else { return }

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "dark"])
            } else {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "light"])
            }
        }
    }
    
    func attachCountryPicker(to textField: UITextField) {
        countryPicker = UIPickerView()
        countryPicker?.delegate = self
        countryPicker?.dataSource = self
        countries = CountryManager.shared.countries
        
        if let currentC = getCurrentCountry() {
            countries?.insert(currentC, at: 0)
        }
        
        textField.inputView = countryPicker
        
        if !areaCodeFields.contains(textField) {
            areaCodeFields.append(textField)
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}

extension BaseScrollingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == countryPicker {
            return countries?.count ?? 0
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let country = countries?[row] else { return "" }
        
        return "\(country.dialingCode ?? "") \(country.englishName)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let country = countries?[row] else { return }
        
        selectedCountry = country
    }
}

extension BaseScrollingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if areaCodeFields.contains(textField) {
            if let selectedCountry = selectedCountry, let index = countries?.firstIndex(of: selectedCountry) {
                countryPicker?.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
}
