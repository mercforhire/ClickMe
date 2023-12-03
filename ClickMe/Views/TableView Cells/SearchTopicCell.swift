//
//  SearchTopicCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-07.
//

import UIKit

class SearchTopicCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: Schedule) {
        if let urlString = data.host.avatarURL, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = data.host.defaultAvatar
        }
        avatar.roundCorners()
        topicImage.image = data.mood.icon()
        titleLabel.text = data.title
    }
}
