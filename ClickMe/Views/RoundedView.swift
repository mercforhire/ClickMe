//
//  RoundedView.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-20.
//

import UIKit

class RoundedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        roundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        roundCorners()
    }
}
