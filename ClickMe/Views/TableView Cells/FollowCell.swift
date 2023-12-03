//
//  FollowCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-27.
//

import UIKit
import Kingfisher

class FollowCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: ListUser, following: Bool) {
        if let urlString = data.avatarURL, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = data.defaultAvatar
        }
        avatar.roundCorners()
        nameLabel.text = data.fullName
        infoLabel.text = data.jobTitle
        followButton.setTitle(following ? "Following" : "Follow", for: .normal)
        if following {
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = themeManager.themeData!.indigo.hexColor
            followButton.addBorder(color: themeManager.themeData!.indigo.hexColor)
        } else {
            followButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
            followButton.backgroundColor = .clear
            followButton.addBorder(color: themeManager.themeData!.textLabel.hexColor)
        }
    }
    
    func config(data: ListUser, blocked: Bool) {
        if let urlString = data.avatarURL, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = data.defaultAvatar
        }
        avatar.roundCorners()
        nameLabel.text = data.fullName
        infoLabel.text = data.jobTitle
        followButton.setTitle(blocked ? "Unblock" : "Block", for: .normal)
        if blocked {
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = themeManager.themeData!.indigo.hexColor
            followButton.addBorder(color: themeManager.themeData!.indigo.hexColor)
        } else {
            followButton.setTitleColor(.black, for: .normal)
            followButton.backgroundColor = .clear
            followButton.addBorder(color: .black)
        }
    }
}
