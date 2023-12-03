//
//  NotificationTableViewCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-22.
//

import UIKit
import BadgeSwift

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var unreadBadge: BadgeSwift!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: NotificationMessage) {
        message.text = data.message
        timestamp.text = timeAgoSince(data.timestamp)
        unreadBadge.isHidden = !data.unread
    }
}
