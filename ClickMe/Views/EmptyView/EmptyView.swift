//
//  EmptyView.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit

enum EmptyViewStyle {
    case networkError
    case noSearchResults
    
    func imageName() -> String {
        switch self {
        case .networkError:
            return "illustration_manreport"
        case .noSearchResults:
            return "illustration_face"
        }
    }
    
    func title() -> String {
        switch self {
        case .networkError:
            return "Network error"
        case .noSearchResults:
            return "No results found"
        }
    }
}

class EmptyView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureUI(style: EmptyViewStyle) {
        imageView.image = UIImage(named: style.imageName())
        titleLabel.text = style.title()
    }
}
