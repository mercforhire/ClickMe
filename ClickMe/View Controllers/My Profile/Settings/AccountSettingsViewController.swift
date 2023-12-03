//
//  AccountSettingsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import UIKit

class AccountSettingsViewController: BaseViewController {
    enum Rows: Int {
        case phone
        case email
        case separator
        case password
        case count
        
        func icon() -> UIImage? {
            switch self {
            case .phone:
                return UIImage(systemName: "phone")
            case .email:
                return UIImage(systemName: "mail")
            case .password:
                return UIImage(systemName: "lock")
            default:
                return nil
            }
        }
        
        func title() -> String {
            switch self {
            case .phone:
                return "Phone Number"
            case .separator:
                return ""
            case .email:
                return "Email"
            case .password:
                return "Change Password"
            default:
                fatalError()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

}

extension AccountSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = Rows(rawValue: indexPath.row) else {
            return 0
        }
        
        switch row {
        case .phone, .password:
            return UITableView.automaticDimension
            
        case .email:
            return userManager.user?.email?.isEmpty ?? true ? 0 : UITableView.automaticDimension
            
        case .separator:
            return 10.0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Rows(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch row {
        case .phone:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingsCell", for: indexPath) as? AccountSettingsCell else {
                return AccountSettingsCell()
            }
            cell.icon.image = row.icon()
            cell.leftLabel.text = row.title()
            cell.rightLabel.text = userManager.user?.phoneNumber ?? ""
            insertSeparator(indexPath: indexPath, cell: cell)
            return cell
            
        case .separator:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                return SeparatorCell()
            }
            return cell
            
        case .email:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingsCell", for: indexPath) as? AccountSettingsCell else {
                return AccountSettingsCell()
            }
            cell.icon.image = row.icon()
            cell.leftLabel.text = row.title()
            cell.rightLabel.text = userManager.user?.email ?? "No email address"
            return cell
            
        case .password:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingsCell", for: indexPath) as? AccountSettingsCell else {
                return AccountSettingsCell()
            }
            cell.icon.image = row.icon()
            cell.leftLabel.text = row.title()
            cell.rightLabel.text = ""
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Rows(rawValue: indexPath.row)
        
        switch row {
        case .phone:
            performSegue(withIdentifier: "goToChangeNumber", sender: self)
            
        case .email:
            performSegue(withIdentifier: "goToChangeEmail", sender: self)
            
        case .password:
            performSegue(withIdentifier: "goToChangePassword", sender: self)
            
        default:
            break
        }
    }
    
    private func insertSeparator(indexPath: IndexPath, cell: UITableViewCell) {
        if indexPath.row == Rows.count.rawValue - 1 {
            cell.contentView.removeOnePixelSeparator()
        } else {
            cell.contentView.insertOnePixelSeparator(color: themeManager.themeData!.defaultBackground.hexColor, inset: 40, position: .bottom)
        }
    }
}
