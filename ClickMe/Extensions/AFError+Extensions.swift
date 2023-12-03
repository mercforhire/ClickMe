//
//  AFError+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-21.
//

import Foundation
import Alamofire

extension AFError {
    func showErrorDialog() {
        DispatchQueue.main.async {
            guard let topVC = UIViewController.topViewController else { return }
            
            guard let errorCode = responseCode else {
                let ac = UIAlertController(title: "", message: "Network error, please check Internet connection.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .default)
                ac.addAction(cancelAction)
                topVC.present(ac, animated: true)
                return
            }
            
            let ac = UIAlertController(title: "", message: "\(errorCode): " + (errorDescription ?? ""), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            topVC.present(ac, animated: true)
        }
    }
}
