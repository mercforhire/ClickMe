//
//  BookingActionCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-08-27.
//

import UIKit

class BookingActionCell: UITableViewCell {
    @IBOutlet weak var logLabel: UILabel!
    
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
