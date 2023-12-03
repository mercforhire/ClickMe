//
//  SpeakerSelectionCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-19.
//

import UIKit
import Kingfisher

class SpeakerSelectionCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmark: UIButton!
    
    private let checkedIcon = UIImage(systemName: "checkmark.circle.fill")!
    private let uncheckedIcon = UIImage(systemName: "circle")!
    private let xIcon = UIImage(systemName: "xmark.circle.fill")!
    private let plusIcon = UIImage(systemName: "plus.circle.fill")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        avatar.roundCorners(style: .completely)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: ListUser, included: Bool) {
        if let urlString = data.avatarURL, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        }
        nameLabel.text = data.fullName
        checkmark.setBackgroundImage(included ? xIcon : plusIcon, for: .normal)
    }
}
