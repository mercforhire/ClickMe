//
//  UICollectionView+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-10.
//

import Foundation
import UIKit

extension UICollectionView {

    var centerMostCell: UICollectionViewCell? {
        guard let superview = superview else { return nil }
        let centerInWindow = superview.convert(center, to: nil)
        guard visibleCells.count > 0 else { return nil }
        var closestCell: UICollectionViewCell?
        for cell in visibleCells {
            guard let sv = cell.superview else { continue }
            let cellFrameInWindow = sv.convert(cell.frame, to: nil)
            if cellFrameInWindow.contains(centerInWindow) {
                closestCell = cell
                break
            }
        }
        return closestCell
    }
    
}
