//
//  SearchPersonCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-07.
//

import UIKit

class SearchPersonCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatar.roundCorners()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: ListUser) {
        if let urlString = data.avatar?.smallUrl, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = data.defaultAvatar
        }
        avatar.roundCorners()
        nameLabel.text = data.fullName
        jobTitleLabel.text = data.jobTitle
    }
}
