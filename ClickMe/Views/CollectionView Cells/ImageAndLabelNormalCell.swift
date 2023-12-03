//
//  ImageAndLabelCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-10.
//

import UIKit

class ImageAndLabelNormalCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(data: Mood) {
        iconImageView.image = data.icon()
        label.text = data.rawValue.capitalizingFirstLetter()
    }
    
    func highlight() {
        contentView.backgroundColor = themeManager.themeData!.indigo.hexColor
        label.textColor = themeManager.themeData!.whiteBackground.hexColor
    }
    
    func unhighlight() {
        contentView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        label.textColor = themeManager.themeData!.textLabel.hexColor
    }
}
