//
//  RoomSpeakerCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-24.
//

import UIKit

class RoomSpeakerCell: UICollectionViewCell {
    @IBOutlet weak var avatarContainer: UIView!
    
    private let speakerView = SpeakerView.fromNib()! as! SpeakerView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarContainer.backgroundColor = .clear
        avatarContainer.fill(with: speakerView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(data: ListUser?, order: Int?) {
        speakerView.config(data: data, order: order)
    }
}
