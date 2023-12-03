//
//  BookOptionsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-18.
//

import UIKit

class BookOptionsViewController: BaseViewController {
    var schedule: Schedule!
    
    enum MenuRows: Int {
        case cancelSchedule
        case report
        case block
        case count
        
        func title() -> String {
            switch self {
            case .cancelSchedule:
                return "Cancel Schedule"
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
            case .cancelSchedule, .report:
                return true
            default:
                return false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    private func goToCancel() {
        if schedule.status == .finished {
            showErrorDialog(error: "Booking is already over")
        } else {
            performSegue(withIdentifier: "goToCancel", sender: self)
        }
    }
    
    private func showBlockConfirmation() {
        if let blockedUsers = userManager.user?.blockedUsers, blockedUsers.contains(schedule.host.identifier) {
            userManager.unblockUser(userId: schedule.host.identifier) { [weak self] success in
                guard let self = self else { return }
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            let alert = UIAlertController(title: nil, message: "Block this person?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                
                self.userManager.blockUser(userId: self.schedule.host.identifier) { [weak self] success in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BookCancelViewController {
            vc.schedule = schedule
        } else if let vc = segue.destination as? ReportMenuViewController {
            vc.userId = schedule.host.identifier
        }
    }
}

extension BookOptionsViewController: UITableViewDataSource, UITableViewDelegate {
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
            cell.label.text = (userManager.user?.blockedUsers?.contains(schedule.host.identifier) ?? false) ? "Unblock" : "Block"
        default:
            cell.label.text = row!.title()
        }
        cell.accessoryType = row!.showArrow() ? .disclosureIndicator : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = MenuRows(rawValue: indexPath.row)
        switch row {
        case .cancelSchedule:
            goToCancel()
        case .report:
            goToReportMenu()
        case .block:
            showBlockConfirmation()
        default:
            break
        }
    }
}
