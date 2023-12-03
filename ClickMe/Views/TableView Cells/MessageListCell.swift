//
//  MessageListCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import UIKit
import BadgeSwift
import SwipeCellKit

class MessageListCell: SwipeTableViewCell {
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var badge: BadgeSwift!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatar.clearImage()
        titleLabel.text = ""
        bodyLabel.text = ""
        timeLabel.text = ""
        badge.text = ""
        badge.isHidden = true
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.clearImage()
        titleLabel.text = ""
        bodyLabel.text = ""
        timeLabel.text = ""
        badge.text = ""
        badge.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    }
    
    func config(data: Message) {
        avatar.config(userProfile: data.user, clickToOpenProfile: false)
        
        titleLabel.text = data.user.fullName
        bodyLabel.text = data.chatMessage.userMessage
        timeLabel.text = timeAgoSince(data.chatMessage.timeStamp)
        badge.isHidden = !(!data.isFromMyself && !data.chatMessage.read)
    }
}
