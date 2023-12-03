//
//  AvatarImage.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import UIKit
import Kingfisher

class AvatarImage: UIView {
    private var userId: Int?
    private var clickToOpenProfile: Bool = false
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        setupImage()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
    }
    
    func reset() {
        userId = nil
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundCorners()
        layer.masksToBounds = true
    }
    
    private func setImage(image: UIImage) {
        UIView.transition(
            with: imageView,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.imageView.image = image
            },
            completion: nil)
        setupShadows()
    }
    
    private func setImageURL(urlString: String) {
        if let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "person")!
        }
        setupShadows()
    }
    
    func config(userProfile: ListUser, clickToOpenProfile: Bool) {
        self.userId = userProfile.identifier
        self.clickToOpenProfile = clickToOpenProfile
        if let url = userProfile.avatar?.smallUrl {
            setImageURL(urlString: url)
        } else {
            imageView.image = userProfile.defaultAvatar
        }
        imageView.backgroundColor = backgroundColor
        
        if clickToOpenProfile {
            let tap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
            addGestureRecognizer(tap)
        }
    }
    
    func hasImage() -> Bool {
        return imageView.image != nil
    }
    
    func clearImage() {
        userId = nil
        setupShadows()
        
        imageView.image = nil
    }
    
    @objc func openProfile() {
        guard let userId = userId else { return }
        
        NotificationCenter.default.post(name: Notifications.OpenProfile, object: nil, userInfo: ["userId": userId])
    }
}

extension AvatarImage {
    private func setupImage() {
        fill(with: imageView)
    }
    
    private func setupShadows() {
        let cornerRadius: CGFloat = 8.0
        clipsToBounds = false
        layer.shadowColor = UIColor.systemGray4.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
    }
}
