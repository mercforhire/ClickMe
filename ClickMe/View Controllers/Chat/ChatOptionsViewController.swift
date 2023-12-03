//
//  ChatDetailsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-14.
//

import UIKit

class ChatOptionsViewController: BaseViewController {
    var user: ListUser!
    
    enum MenuRows: Int {
        case history
        case report
        case block
        case count
        
        func title() -> String {
            switch self {
            case .history:
                return "ClickMe History"
            case .report:
                return "Report"
            case .block:
                return "Block"
            default:
                return ""
            }
        }
        
        func showArrow() -> Bool {
            switch self {
            case .history, .report:
                return true
            default:
                return false
            }
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableview.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func showBlockConfirmation() {
        if let blockedUsers = userManager.user?.blockedUsers, blockedUsers.contains(user.identifier) {
            userManager.unblockUser(userId: user.identifier) { [weak self] success in
                guard let self = self else { return }
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            let alert = UIAlertController(title: nil, message: "Block this person?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                
                self.userManager.blockUser(userId: self.user.identifier) { [weak self] success in
                    guard let self = self else { return }
                    
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func goToReportMenu() {
        performSegue(withIdentifier: "goToReport", sender: self)
    }
    
    private func goToHistoryScreen() {
        performSegue(withIdentifier: "goToHistory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReportMenuViewController {
            vc.userId = user.identifier
        } else if let vc = segue.destination as? HistoryViewController {
            vc.user = user
        }
    }
}

extension ChatOptionsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuRows.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailMenuCell", for: indexPath) as? DetailMenuCell else {
            return DetailMenuCell()
        }
        
        let row = MenuRows(rawValue: indexPath.row)
        switch row {
        case .block:
            cell.label.text = userManager.user?.blockedUsers?.contains(user.identifier) ?? false ? "Unblock" : "Block"
        default:
            cell.label.text = row!.title()
        }
        cell.accessoryType = row!.showArrow() ? .disclosureIndicator : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = MenuRows(rawValue: indexPath.row)
        switch row {
        case .history:
            goToHistoryScreen()
        case .report:
            goToReportMenu()
        case .block:
            showBlockConfirmation()
        default:
            break
        }
    }
}
