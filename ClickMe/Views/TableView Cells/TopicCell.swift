//
//  TopicCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-07.
//

import UIKit
import Kingfisher

class TopicCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var skillIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var topicNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: Schedule, isSaved: Bool) {
        if let urlString = data.host.avatar?.smallUrl, let url = URL(string: urlString) {
            profileView.kf.setImage(with: url)
        } else {
            profileView.image = data.host.defaultAvatar
        }
        skillIcon.image = data.mood.icon()
        nameLabel.text = data.host.fullName
        jobTitleLabel.text = data.host.jobDescription
        topicNameLabel.text = data.title
        timeLabel.text = data.timeAndDuration
        costLabel.text = "\(data.coin)"
    }
}
