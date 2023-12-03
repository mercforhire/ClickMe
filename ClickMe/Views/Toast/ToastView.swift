//
//  ToastView.swift
//  Phoenix
//
//  Created by Illya Gordiyenko on 2018-06-06.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

class ToastView: UIView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {

        Bundle.main.loadNibNamed("ToastView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        descriptionLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textColor = themeManager.themeData!.whiteBackground.hexColor
        iconImageView.tintColor = themeManager.themeData!.whiteBackground.hexColor
        containerView.backgroundColor = themeManager.themeData!.indigo.hexColor
        
    }
}
