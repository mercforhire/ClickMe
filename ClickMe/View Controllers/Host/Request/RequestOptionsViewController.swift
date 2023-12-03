//
//  RequestOptionsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-25.
//

import UIKit

class RequestOptionsViewController: BaseViewController {
    var schedule: Schedule!
    
    enum MenuRows: Int {
        case cancelSchedule
        case deleteSchedule
        case count
        
        func title() -> String {
            switch self {
            case .cancelSchedule:
                return "Cancel Schedule"
            case .deleteSchedule:
                return "Delete Schedule"
            default:
                return ""
            }
        }
        
        func showArrow() -> Bool {
            switch self {
            case .cancelSchedule:
                return true
            case .deleteSchedule:
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
    
    private func goToCancel() {
        if schedule.status != .upcoming {
            showErrorDialog(error: "Can't cancel a booking that's not accepted.")
        } else {
            performSegue(withIdentifier: "goToCancel", sender: self)
        }
    }
    
    private func goToDelete() {
        if schedule.status != .open {
            showErrorDialog(error: "Can't delete a booking that's already pending or accepted")
        } else {
            FullScreenSpinner().show()
            api.deleteSchedule(scheduleId: schedule.identifier) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RequestRejectOrCancelViewController {
            vc.schedule = schedule
            vc.action = .cancel
        }
    }
}

extension RequestOptionsViewController: UITableViewDataSource, UITableViewDelegate {
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
        cell.label.text = row!.title()
        cell.accessoryType = row!.showArrow() ? .disclosureIndicator : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = MenuRows(rawValue: indexPath.row)
        switch row {
        case .cancelSchedule:
            goToCancel()
        case .deleteSchedule:
            goToDelete()
        default:
            break
        }
    }
}
