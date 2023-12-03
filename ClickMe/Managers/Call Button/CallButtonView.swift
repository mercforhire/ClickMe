//
//  HIDButtonView.swift
//  ola
//
//  Created by Leon Chen on 2021-05-03.
//  Copyright © 2021 Angus. All rights reserved.
//

import UIKit

class CallButtonView: UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CallButtonView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.layer.cornerRadius = containerView.frame.height / 2
        iconImageView.tintColor = themeManager.themeData!.whiteBackground.hexColor
        iconContainer.backgroundColor = themeManager.themeData!.indigo.hexColor
    }

}
