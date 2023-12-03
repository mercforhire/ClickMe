//
//  SettingsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import UIKit

class SettingsViewController: BaseViewController {
    enum Rows: Int {
        case account
        case blockedUsers
        case separator1
        case support
        case feedback
        case separator2
        case signOut
        case count
        
        func title() -> String {
            switch self {
            case .account:
                return "Account Setting"
            case .blockedUsers:
                return "Blocked Users"
            case .support:
                return "Support & FAQ"
            case .feedback:
                return "Feedback"
            case .signOut:
                return "Sign Out"
            default:
                return "DIV"
            }
        }
        
        func icon() -> UIImage {
            switch self {
            case .account:
                return UIImage(systemName: "gearshape")!
            case .blockedUsers:
                return UIImage(systemName: "gearshape")!
            case .support:
                return UIImage(systemName: "questionmark.circle")!
            case .feedback:
                return UIImage(systemName: "exclamationmark.bubble.fill")!
            case .signOut:
                return UIImage(named: "logout")!
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

    
    private func showFeedbackDialog() {
        let ac = UIAlertController(title: "Feedback", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "Title"
            textfield.keyboardType = .asciiCapable
        }
        
        ac.addTextField { textfield in
            textfield.placeholder = "Comments"
            textfield.keyboardType = .asciiCapable
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            if let title = ac.textFields![0].text,
               let comments = ac.textFields![1].text,
               !title.isEmpty, !comments.isEmpty {
                
                FullScreenSpinner().show()
                self?.api.postFeedback(title: title, feedback: comments) { result in
                    FullScreenSpinner().hide()
                    
                    switch result {
                    case .success:
                        showErrorDialog(error: "Thank you for the feedback!")
                    case .failure(let error):
                        if error.responseCode == nil {
                            showNetworkErrorDialog()
                        } else {
                            error.showErrorDialog()
                            print("Error occured \(error)")
                        }
                    }
                }
            } else {
                showErrorDialog(error: "Please enter a title and fill the comments")
            }
        }
        ac.addAction(submitAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = themeManager.themeData!.textLabel.hexColor
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 22.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Settings"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = Rows(rawValue: indexPath.row) else {
            return 0
        }
        
        switch row {
        case .separator1, .separator2:
            return 10.0
            
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Rows(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        if row.title() == "DIV" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                return SeparatorCell()
            }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuCell", for: indexPath) as? ProfileMenuCell else {
            return ProfileMenuCell()
        }
        
        cell.icon.image = row.icon()
        cell.label.text = row.title()
        
        if indexPath.row == Rows.count.rawValue - 1 {
            cell.contentView.removeOnePixelSeparator()
        } else {
            cell.contentView.insertOnePixelSeparator(color: themeManager.themeData!.defaultBackground.hexColor, inset: 40, position: .bottom)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Rows(rawValue: indexPath.row)
        switch row {
        case .account:
            performSegue(withIdentifier: "goToAccountSettings", sender: self)
        case .blockedUsers:
            performSegue(withIdentifier: "goToBlockedUsers", sender: self)
        case .support:
            openURLInBrowser(url: URL(string: "https://www.cpclickme.com/faq.html")!)
        case .feedback:
            showFeedbackDialog()
        case .signOut:
            logout()
        default:
            break
        }
    }
}
