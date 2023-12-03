//
//  ProfileSwitchViewCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-25.
//

import UIKit

class ProfileSwitchViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        container.roundCorners()
        selectionStyle = .none
        toggle.isOn = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
