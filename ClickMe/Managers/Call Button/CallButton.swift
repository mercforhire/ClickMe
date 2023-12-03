//
//  HIDButton.swift
//  Experience
//
//  Created by Leon Chen on 2021-05-03.
//  Copyright © 2021 Angus. All rights reserved.
//

import Foundation
import UIKit

class CallButton: NSObject {
    private static let defaultHeight: CGFloat = 80.0
    private static let liveUpdateFrequency: TimeInterval = 2.0
    
    private var toastView: CallButtonView?
    private var timer: Timer?
    private let manager = AgoraManager.shared
    
    func showButton() {
        let buttonHeight: CGFloat = CallButton.defaultHeight
        
        guard let screenWidth = UIViewController.window?.rootViewController?.view.frame.width else { return }
        guard let screenHeight = UIViewController.window?.rootViewController?.view.frame.height else { return }
        
        if toastView == nil {
            toastView = CallButtonView(frame: CGRect(x: screenWidth - buttonHeight,
                                                    y: screenHeight * 0.8 - buttonHeight / 2,
                                                    width: buttonHeight,
                                                    height: buttonHeight))
            toastView?.button.addTarget(self, action: #selector(keyPressed), for: UIControl.Event.touchUpInside)
        }
        
        toastView?.button.isEnabled = true
        UIViewController.window?.rootViewController?.view.addSubview(toastView!)
    }
    
    func hideButton() {
        guard let toastView = toastView else { return }
        
        toastView.removeFromSuperview()
    }
    
    @objc private func keyPressed() {
        manager.openCallScreen()
    }
    
    func startObserveAgoraManager() {
        manager.addObserver(self, forKeyPath: "inInACall", options: [.initial, .new], context: nil)
        manager.addObserver(self, forKeyPath: "fullScreenCallViewOpened", options: [.initial, .new], context: nil)
    }
    
    func stopObserveAgoraManager() {
        if manager.observationInfo != nil {
            manager.removeObserver(self, forKeyPath: "inInACall")
            manager.removeObserver(self, forKeyPath: "fullScreenCallViewOpened")
        }
    }
    
    deinit {
        stopObserveAgoraManager()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "fullScreenCallViewOpened" {
            let fullScreenCallViewOpened = change?[.newKey] as? Bool ?? false
            if fullScreenCallViewOpened {
                hideButton()
            } else {
                if manager.inInACall {
                    showButton()
                }
            }
        } else if keyPath == "inInACall" {
            let inInACall = change?[.newKey] as? Bool ?? false
            if inInACall {
                if !manager.fullScreenCallViewOpened {
                    showButton()
                }
            } else {
                hideButton()
            }
        }
    }
}
