//
//  SpeakerView.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-23.
//

import Foundation
import UIKit

class SpeakerView: UIView {
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var speakerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        orderLabel.roundCorners(style: .completely)
        orderLabel.addBorder(color: .lightGray)
        avatar.addBorder()
        speakerButton.roundCorners(style: .completely)
        speakerButton.layer.shadowColor = UIColor.black.cgColor
        speakerButton.layer.shadowOpacity = 0.2
        speakerButton.layer.shadowOffset = .init(width: 0, height: 3)
        speakerButton.layer.shadowRadius = 2
        orderLabel.text = ""
    }
    
    func config(data: ListUser?, order: Int? = nil) {
        if let order = order {
            orderLabel.text = "\(order)"
            orderLabel.isHidden = false

        } else {
            orderLabel.text = ""
            orderLabel.isHidden = true
        }
        
        if let data = data {
            avatar.config(userProfile: data, clickToOpenProfile: true)
        }
        nameLabel.text = data?.firstName
        speakerButton.isHidden = data == nil
    }
    
    func muted() {
        let icon = UIImage(systemName: "mic.slash.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        speakerButton.setImage(icon, for: .normal)
    }
    
    func canSpeak() {
        let icon = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        speakerButton.setImage(icon, for: .normal)
    }
}
