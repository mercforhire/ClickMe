//
//  SearchRoomCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-22.
//

import UIKit

class SearchRoomCell: UITableViewCell {
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var roomTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(room: GroupChatRoom) {
        categoryIcon.image = room.mood.icon()
        roomTitle.text = room.title
    }
}
