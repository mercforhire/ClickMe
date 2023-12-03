//
//  ScheduleCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-24.
//

import UIKit
import Kingfisher

class ScheduleCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var skillIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    
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
        if let urlString = data.host.avatar?.smallUrl, let url = URL(string: urlString) {
            profileView.kf.setImage(with: url)
        } else {
            profileView.image = data.host.defaultAvatar
        }
        skillIcon.image = data.mood.icon()
        nameLabel.text = data.host.fullName
        jobTitleLabel.text = data.host.jobDescription
        timeLabel.text = data.timeAndDuration
        titleLabel.text = data.title
        pendingLabel.text = data.status.description()
        pendingLabel.textColor = data.status.labelColor()
    }
}
