//
//  RechargeOptionCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-26.
//

import UIKit
import WebKit

class RechargeOptionCell: UITableViewCell {
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var descriptionLabel: ThemeIndigoLabel!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    
    func setupUI() {
        container2.backgroundColor = isSelected ? themeManager.themeData!.indigo.hexColor : themeManager.themeData!.whiteBackground.hexColor
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        container.layer.cornerRadius = 28.0
        container1.layer.cornerRadius = container1.frame.height / 2
        container2.layer.cornerRadius = container2.frame.height / 2
        
        coinsLabel.text = ""
        costLabel.text = ""
        descriptionLabel.text = ""
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        container2.backgroundColor = selected ? themeManager.themeData!.indigo.hexColor : themeManager.themeData!.whiteBackground.hexColor
    }
    
    func config(data: RechargeOptionDataModel) {
        coinsLabel.text = "\(data.coins) coins"
        costLabel.text = "$\(String(format: "%.2f", data.cost))"
        descriptionLabel.text = data.description
        descriptionLabel.isHidden = data.description.isEmpty
    }

}
