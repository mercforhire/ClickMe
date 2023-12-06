//
//  AccountSettingsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import UIKit

class AccountSettingsViewController: BaseViewController {
    enum Rows: Int {
        case email
        case count
        
        func icon() -> UIImage? {
            switch self {
            case .email:
                return UIImage(systemName: "mail")
            default:
                return nil
            }
        }
        
        func title() -> String {
            switch self {
            case .email:
                return "Email"
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
        case .email:
            return userManager.user?.email?.isEmpty ?? true ? 0 : UITableView.automaticDimension
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Rows(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch row {
        case .email:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingsCell", for: indexPath) as? AccountSettingsCell else {
                return AccountSettingsCell()
            }
            cell.icon.image = row.icon()
            cell.leftLabel.text = row.title()
            cell.rightLabel.text = userManager.user?.email ?? "No email address"
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Rows(rawValue: indexPath.row)
        
        switch row {
        case .email:
            performSegue(withIdentifier: "goToChangeEmail", sender: self)
            
        default:
            break
        }
    }

}
