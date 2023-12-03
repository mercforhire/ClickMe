//
//  ProfileTextCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-11.
//

import UIKit

class ProfileTextCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        container.roundCorners()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
