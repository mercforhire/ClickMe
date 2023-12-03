//
//  TransactionCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-26.
//

import UIKit
import Kingfisher

class TransactionCell: UITableViewCell {
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Transaction) {
        if let otherUser = data.theOther {
            avatar.config(userProfile: otherUser, clickToOpenProfile: true)
            coinImageView.isHidden = true
        } else {
            coinImageView.isHidden = false
        }
        nameLabel.text = data.theOther?.fullName ?? ""
        bodyLabel.text = data.schedule?.title ?? data.actionType.name()
        dateLabel.text = DateUtil.convert(input: data.createdAt,
                                          outputFormat: .format1)
        amountLabel.text = "\(data.amount > 0 ? "+" : "")\(data.amount)"
        amountLabel.textColor = data.amountColor
    }
}
