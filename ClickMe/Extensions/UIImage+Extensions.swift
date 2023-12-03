//
//  UIImage+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-21.
//

import Foundation
import UIKit

extension UIImage {
    var jpeg: Data? { jpegData(compressionQuality: 0.9) }  // QUALITY min = 0 / max = 1
    var png: Data? { pngData() }
}
