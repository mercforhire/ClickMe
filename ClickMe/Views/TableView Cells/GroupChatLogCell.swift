//
//  GroupChatLogCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-24.
//

import UIKit

class GroupChatLogCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var logLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
