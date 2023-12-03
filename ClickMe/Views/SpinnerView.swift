//
//  SpinnerView.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-12.
//

import Foundation
import UIKit

class SpinnerView: UIView {
    private var observer: NSObjectProtocol?
    
    private(set) var isAnimationPlaying = false
    private let animationViewSide: CGFloat = 250.0
    private let lottieWrapper = LottieWrapper(with: "paperplane")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = themeManager.theme == .light ? UIColor(white: 1.0, alpha: 0.6) : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        addSubview(lottieWrapper)
        
        lottieWrapper.translatesAutoresizingMaskIntoConstraints = false
        lottieWrapper.centerXAnchor.constraint(equalTo: centerXAnchor).isActive  = true
        lottieWrapper.centerYAnchor.constraint(equalTo: centerYAnchor).isActive  = true
        lottieWrapper.heightAnchor.constraint(equalToConstant: animationViewSide).isActive = true
        lottieWrapper.widthAnchor.constraint(equalToConstant: animationViewSide).isActive = true
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    func startAnimation(bgAlpha: CGFloat = 0.6) {
        backgroundColor = UIColor(white: 1.0, alpha: bgAlpha)
        lottieWrapper.play()
        isAnimationPlaying = true
    }
    
    func stopAnimation() {
        lottieWrapper.stop()
        isAnimationPlaying = false
    }
}
