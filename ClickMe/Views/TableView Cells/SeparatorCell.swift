//
//  SeparatorCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import UIKit

class SeparatorCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
