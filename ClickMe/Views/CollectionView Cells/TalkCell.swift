//
//  TalkCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-10.
//

import UIKit

class TalkCell: UICollectionViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundCorners(style: .medium)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(data: Schedule, review: Review) {
        categoryImageView.image = data.mood.icon()
        ratingLabel.text = "★\(review.rating)"
    }
}
