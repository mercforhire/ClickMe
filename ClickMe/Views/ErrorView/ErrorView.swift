//
//  ErrorView.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit

enum EmptyViewStyle {
    case noData
    case noSearchResults
    case noFollowing
    case noSchedules
    
    func imageName() -> String {
        switch self {
        case .noData:
            return "Empty"
        case .noSearchResults:
            return "Empty"
        case .noFollowing:
            return "wait"
        case .noSchedules:
            return "letter"
        }
    }
    
    func title() -> String {
        switch self {
        case .noData:
            return "No results to show"
        case .noSearchResults:
            return "No results found"
        case .noFollowing:
            return "Nothing found"
        case .noSchedules:
            return "Nothing found"
        }
    }
    
    func subtitle() -> String? {
        switch self {
        case .noData:
            return nil
        case .noSearchResults:
            return "Try adjusting your search or filter to find what you are looking for."
        case .noFollowing:
            return "Try to follow more friends."
        case .noSchedules:
            return "Explore to discover more interesting topics!"
        }
    }
}

class ErrorView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subtitleLabel.isHidden = true
    }
    
    func configureUI(style: EmptyViewStyle) {
        imageView.image = UIImage(named: style.imageName())
        titleLabel.text = style.title()
        if let subtitle = style.subtitle() {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}
