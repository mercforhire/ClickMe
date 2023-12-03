//
//  PersonCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit
import Kingfisher

class PersonCell: UITableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verifiedImage: UIImageView!
    @IBOutlet weak var favoritedImage: UIImageView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var hotIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        hotIcon.roundCorners(style: .completely)
        hotIcon.layer.borderWidth = 1.0
        hotIcon.layer.borderColor = UIColor.white.cgColor
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: ListUser, favorited: Bool) {
        nameLabel.text = data.fullName
        occupationLabel.text = data.jobDescription
        
        if let photoURL = data.profileURL, let url = URL(string: photoURL) {
            photoView.kf.setImage(with: url)
        } else {
            photoView.image = data.defaultAvatar
        }
        
        verifiedImage.isHidden = data.photoVerify != .approved
        favoritedImage.image = favorited ? UIImage(systemName: "heart.fill")! : UIImage(systemName: "heart")!
        categoryImage.image = data.field?.icon()
        hotIcon.setTitle(" \(data.receivedLikesFrom?.count ?? 0)", for: .normal)
    }
}
