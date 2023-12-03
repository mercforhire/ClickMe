//
//  TemplateTableViewCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-06.
//

import UIKit

class TemplateTableViewCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var categoryLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var duplicateButton: UIButton!
    @IBOutlet weak var useButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        deleteButton.roundCorners(style: .completely)
        deleteButton.layer.shadowColor = UIColor.black.cgColor
        deleteButton.layer.shadowOpacity = 0.3
        deleteButton.layer.shadowOffset = .init(width: 0, height: 3)
        deleteButton.layer.shadowRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Template) {
        categoryLabel.image = data.mood.icon()
        titleLabel.text = data.title
        descriptionLabel.text = data.description
    }
}
