//
//  RechargeViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-26.
//

import UIKit
import Stripe

struct RechargeOptionDataModel: Equatable {
    var coins: Int
    var cost: Double
    var packageOption: String
    var description: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.description == rhs.description
    }
    
    static func getSelections() -> [RechargeOptionDataModel] {
        let s1 = RechargeOptionDataModel(coins: 1000, cost: 10.0, packageOption: "basic", description: "")
        let s2 = RechargeOptionDataModel(coins: 5200, cost: 50.0, packageOption: "advanced", description: "Get 4% more coins!")
        let s3 = RechargeOptionDataModel(coins: 10800, cost: 100.0, packageOption: "premium", description: "Get 8% more coins!")
        let s4 = RechargeOptionDataModel(coins: 22000, cost: 200.0, packageOption: "best", description: "Get 10% more coins!")
        return [s1, s2, s3, s4]
    }
}

class RechargeViewController: BaseViewController {
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var options: [RechargeOptionDataModel] = RechargeOptionDataModel.getSelections()
    var selectedOption: RechargeOptionDataModel?
    var paymentSheet: PaymentSheet?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.contentInset = .init(top: 50, left: 0, bottom: 80, right: 0)
        topContainer.layer.cornerRadius = 50.0
    }
    
    @IBAction func nextPress(_ sender: UIButton) {
        if let selectedOption = selectedOption {
            
            sender.isEnabled = false
            FullScreenSpinner().show()
            
            api.chargeNew(packageOption: selectedOption.packageOption) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.presentStripe(response: response, sender: sender)
                case .failure(let error):
                    sender.isEnabled = true
                    FullScreenSpinner().hide()
                    
                    guard let _ = error.responseCode else {
                        showNetworkErrorDialog()
                        return
                    }
                    
                    error.showErrorDialog()
                }
            }
        } else {
            let ac = UIAlertController(title: nil, message: "Please select an option", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
        }
    }
    
    private func presentStripe(response: ChargeNewResponse, sender: UIButton) {
        STPAPIClient.shared.publishableKey = response.publishableKey
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "CP ClickMe Inc."
        configuration.customer = .init(id: response.customer, ephemeralKeySecret: response.ephemeralKey)
        // Set `allowsDelayedPaymentMethods` to true if your business can handle payment
        // methods that complete payment after a delay, like SEPA Debit and Sofort.
        configuration.allowsDelayedPaymentMethods = true
        paymentSheet = PaymentSheet(paymentIntentClientSecret: response.paymentIntent, configuration: configuration)
        
        paymentSheet?.present(from: self) { [weak self] paymentResult in
            sender.isEnabled = true
            FullScreenSpinner().hide()
            
            // MARK: Handle the payment result
            switch paymentResult {
            case .completed:
                self?.performSegue(withIdentifier: "goToSuccess", sender: self)
            case .canceled:
                print("Canceled!")
            case .failed(let error):
                print("Payment failed: \(error)")
            }
        }
    }
}

extension RechargeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RechargeOptionCell", for: indexPath) as? RechargeOptionCell else {
            return RechargeOptionCell()
        }
        
        let option = options[indexPath.row]
        cell.config(data: option)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedOption == options[indexPath.row] {
            tableView.deselectRow(at: indexPath, animated: false)
            selectedOption = nil
        } else {
            selectedOption = options[indexPath.row]
        }
    }
}
