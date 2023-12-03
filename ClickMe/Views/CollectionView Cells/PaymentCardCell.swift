//
//  PaymentCardCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-13.
//

import UIKit

class PaymentCardCell: UICollectionViewCell {
    @IBOutlet weak var cardNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func highlight() {
        contentView.backgroundColor = UIColor.systemIndigo
        cardNameLabel.textColor = UIColor.white
    }
    
    func unhighlight() {
        contentView.backgroundColor = UIColor.white
        cardNameLabel.textColor = UIColor.black
    }
}

class PaymentCardDetailedCell: UICollectionViewCell {
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardNumLabel: ThemeBlackTextLabel!
    @IBOutlet weak var cardDateLabel: ThemeDarkTextLabel!
    
    func setupUI() {
        if isHighlighted {
            contentView.backgroundColor = themeManager.themeData!.indigo.hexColor
            cardNameLabel.textColor = themeManager.themeData!.whiteBackground.hexColor
        } else {
            contentView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
            cardNameLabel.textColor = themeManager.themeData!.darkLabel.hexColor
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.darkGray.cgColor
        
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func highlight() {
        contentView.backgroundColor = themeManager.themeData!.indigo.hexColor
        cardNameLabel.textColor = themeManager.themeData!.whiteBackground.hexColor
        isHighlighted = true
    }
    
    func unhighlight() {
        contentView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        cardNameLabel.textColor = themeManager.themeData!.darkLabel.hexColor
        isHighlighted = false
    }
}
