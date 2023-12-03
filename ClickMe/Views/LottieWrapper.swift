//
//  LottieWrapper.swift
//  Phoenix
//
//  Created by Adam Borzecki on 9/11/18.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit
import Lottie

class LottieWrapper: UIView {
    var lottieAnimation: AnimationView?
    var tapGestureRecognizer: UITapGestureRecognizer?
    init(with name: String, repeatOnTouch: Bool = false) {
        super.init(frame: .zero)
        self.name = name
        self.lottieAnimation = AnimationView(name: name)
        self.fill(with: lottieAnimation!)
        
        if repeatOnTouch {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
            self.lottieAnimation?.addGestureRecognizer(tapGestureRecognizer!)
        }
        
        layoutIfNeeded()
    }
    
    deinit {
        lottieAnimation?.stop()
        tapGestureRecognizer?.removeTarget(self, action: #selector(didTap))
        tapGestureRecognizer = nil
    }
    
    @objc func didTap() {
        lottieAnimation?.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        lottieAnimation?.play()
    }
    
    func stop() {
        lottieAnimation?.stop()
    }
    
    var loopAnimation: Bool = true {
        didSet {
            lottieAnimation?.loopMode = loopAnimation ? .loop : .playOnce
        }
    }
    
    var name: String = "" {
        didSet {
            self.lottieAnimation?.animation = Animation.named(name)
        }
    }
    
    override var contentMode: UIView.ContentMode {
        didSet {
            lottieAnimation?.contentMode = contentMode
        }
    }
}
