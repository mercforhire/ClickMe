//
//  ChatCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-13.
//

import UIKit
import UILabel_Copyable

protocol ChatCellDelegate: class {
    func profileTapped(user: ListUser)
    func topicTapped(schedule: SimpleSchedule)
}

class ChatCell: UITableViewCell {
    @IBOutlet weak var topicContainer: UIView!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var message: Message?
    weak var delegate: ChatCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatar.clearImage()
        topicContainer.isHidden = true
        topicLabel.text = ""
        topicLabel.isCopyingEnabled = true
        messageLabel.isCopyingEnabled = true
        
        let topicTapped: UITapGestureRecognizer = UITapGestureRecognizer()
        topicTapped.addTarget(self, action: #selector(topicTap))
        topicContainer.addGestureRecognizer(topicTapped)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.clearImage()
        topicContainer.isHidden = true
        categoryLabel.text = ""
        topicLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Message, speaker: ListUser, clickToOpenProfile: Bool) {
        message = data
        avatar.config(userProfile: speaker, clickToOpenProfile: clickToOpenProfile)
        messageLabel.text = data.chatMessage.userMessage
        timeLabel.text = timeAgoSince(data.chatMessage.timeStamp)
        
        if let topic = data.schedule {
            topicContainer.isHidden = false
            categoryLabel.text = topic.mood.rawValue.capitalizingFirstLetter()
            topicLabel.text = topic.title
        }
    }
    
    @objc private func topicTap() {
        guard let schedule = message?.schedule else { return }
        
        delegate?.topicTapped(schedule: schedule)
    }
}
