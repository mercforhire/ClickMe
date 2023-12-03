//
//  ReportMenuViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-14.
//

import UIKit

class ReportMenuViewController: BaseViewController {
    var userId: Int!
    
    enum MenuRows: Int {
        case fake
        case spam
        case fraud
        case porn
        case harrass
        case other
        case count
        
        func title() -> String {
            switch self {
            case .fake:
                return "Fake profile"
            case .spam:
                return "Advertiser/Spam"
            case .fraud:
                return "Fraud"
            case .porn:
                return "Explicit Content"
            case .harrass:
                return "Profanity/Harassment"
            case .other:
                return "Others"
            default:
                return ""
            }
        }
    }
    
    private var pickedReason: String = ""
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func goToReportDetailsView(reason: String) {
        performSegue(withIdentifier: "goToReportDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReportDetailsViewController {
            vc.userId = userId
            vc.reason = pickedReason
        }
    }
}

extension ReportMenuViewController: UITableViewDataSource, UITableViewDelegate {
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = MenuRows(rawValue: indexPath.row) else { return }
        
        pickedReason = row.title()
        goToReportDetailsView(reason: row.title())
    }
}
