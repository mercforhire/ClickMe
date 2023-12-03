//
//  ReviewCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-29.
//

import UIKit
import Cosmos
import ExpandableLabel
import Kingfisher

class ReviewCell: UITableViewCell, ExpandableLabelDelegate {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var bodyContainer: UIView!
    @IBOutlet weak var bodyLabel: ExpandableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        bodyLabel.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: Review) {
        if let urlString = data.writer.avatar?.smallUrl, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = data.writer.defaultAvatar
        }
        
        nameLabel.text = data.writer.firstName.capitalizingFirstLetter()
        ratingView.rating = Double(data.rating)
        bodyLabel.text = data.body
    }

    func reset() {
        avatar.image = UIImage(named: "person.crop.square.fill")
        nameLabel.text = ""
        ratingView.rating = 3
        bodyLabel.text = ""
    }
    
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        setNeedsLayout()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        setNeedsLayout()
    }
}
