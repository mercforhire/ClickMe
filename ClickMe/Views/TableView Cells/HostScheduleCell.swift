//
//  HostScheduleCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-02.
//

import UIKit
import Kingfisher

class HostScheduleCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bookerAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bookerAvatar.layer.cornerRadius = bookerAvatar.frame.height / 2
        bookerAvatar.isHidden = true
        statusLabel.text = ""
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookerAvatar.isHidden = true
        statusLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Schedule, showDate: Bool) {
        categoryIcon.image = data.mood.icon()
        timeLabel.text = showDate ? DateUtil.convert(input: data.startTime, outputFormat: .format10) : DateUtil.convert(input: data.startTime, outputFormat: .format8)
        titleLabel.text = data.title
        durationLabel.text = data.intradayDuration
        costLabel.text = "\(data.coin)"
        
        if let booker = data.booker {
            if let urlString = booker.avatar?.smallUrl, let url = URL(string: urlString) {
                bookerAvatar.kf.setImage(with: url)
            } else {
                bookerAvatar.image = booker.defaultAvatar
            }
            bookerAvatar.isHidden = false
        } else {
            bookerAvatar.isHidden = true
        }
        
        statusLabel.text = data.status.description().uppercased()
        statusLabel.textColor = data.status.labelColor()
    }
}
