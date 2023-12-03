//
//  RoomCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-14.
//

import UIKit

class RoomCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var hostAvatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var userCountLabel: UILabel!
    @IBOutlet weak var userCountLabelMargin: NSLayoutConstraint!
    @IBOutlet weak var avatar1: UIImageView!
    @IBOutlet weak var avatar2: UIImageView!
    @IBOutlet weak var avatar3: UIImageView!
    @IBOutlet weak var avatar4: UIImageView!
    @IBOutlet weak var avatar5: UIImageView!
    @IBOutlet weak var avatar6: UIImageView!
    @IBOutlet weak var avatar7: UIImageView!
    
    private let MaxAvatarsCount = 7
    private var avatarImageViews: [UIImageView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        avatarImageViews.append(avatar1)
        avatarImageViews.append(avatar2)
        avatarImageViews.append(avatar3)
        avatarImageViews.append(avatar4)
        avatarImageViews.append(avatar5)
        avatarImageViews.append(avatar6)
        avatarImageViews.append(avatar7)
        for avatarImageView in avatarImageViews {
            avatarImageView.isHidden = true
            avatarImageView.roundCorners(style: .completely)
            avatarImageView.layer.borderWidth = 1.0
            avatarImageView.layer.borderColor = UIColor.white.cgColor
        }
        
        nameLabel.text = ""
        occupationLabel.text = ""
        topicLabel.text = ""
        userCountLabel.text = ""
    }

    func config(room: GroupChatRoom) {
        if let urlString = room.host.avatarURL, let url = URL(string: urlString) {
            hostAvatar.kf.setImage(with: url)
        }
        nameLabel.text = room.host.fullName
        occupationLabel.text = room.host.jobDescription
        topicLabel.text = room.title
        if room.speakers.count > MaxAvatarsCount {
            userCountLabel.text = "& \(room.speakers.count - MaxAvatarsCount) others"
        } else {
            userCountLabel.text = ""
        }
        for i in 0..<MaxAvatarsCount {
            if i < room.speakers.count {
                if let urlString = room.speakers[i].avatarURL, let url = URL(string: urlString) {
                    avatarImageViews[i].kf.setImage(with: url)
                }
                avatarImageViews[i].isHidden = false
            } else {
                avatarImageViews[i].isHidden = true
            }
        }
        userCountLabelMargin.constant = CGFloat(20 + 10) + CGFloat(min(room.speakers.count, MaxAvatarsCount)) * 24 - 5 * CGFloat(room.guests.count - 1)
    }
}
