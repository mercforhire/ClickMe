//
//  TransactionsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-26.
//

import UIKit

class TransactionsViewController: BaseViewController {
    @IBOutlet weak var tableview: UITableView!
    
    var transactions: [Transaction]? {
        didSet {
            tableview.reloadData()
            noResultsViewContainer.isHidden = !(transactions?.isEmpty ?? true)
        }
    }
    private var selected: Schedule?
    
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTransactions()
    }
    
    private func fetchTransactions() {
        transactions == nil ? FullScreenSpinner().show() : nil
        api.getTransactionHistory { [weak self] result in
            guard let self = self else { return }
            
            self.transactions == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.transactions = response
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TopicDetailViewController {
            vc.schedule = selected
        }
    }
}

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell, let transaction = transactions?[indexPath.row] else {
            return TransactionCell()
        }
        
        cell.config(data: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let transaction = transactions?[indexPath.row] else {
            return
        }
        
        if let schedule = transaction.schedule {
            selected = schedule
            performSegue(withIdentifier: "goToBookingDetails", sender: self)
        }
    }
}
