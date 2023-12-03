//
//  ProfilePhotosCollectionViewLayout.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-11.
//

import UIKit

class ProfilePhotosCollectionViewLayout: UICollectionViewLayout {
    private var maxNumberOfPhotos = 6
    
    //An array to cache the calculated attributes
    private var cache = [UICollectionViewLayoutAttributes]()
    
    //For content size
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    //Setting the content size
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    private var largeCellWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        
        return collectionView.frame.width / 3 * 2
    }
    
    private var cellWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        
        return collectionView.frame.width / 3
    }
    
    override func prepare() {
        // We begin measuring the location of items only if the cache is empty
        guard cache.isEmpty == true else {return}
        
        // Photo order:
        // 1 1 2
        // 1 1 3
        // 4 5 6
        var xOffset = [CGFloat]()
        for number in 1...maxNumberOfPhotos {
            switch number {
            case 1,4:
                xOffset.append(0)
            case 2,3,6:
                xOffset.append(largeCellWidth)
            case 5:
                xOffset.append(cellWidth)
            default:
                break
            }
        }
        
        var yOffset = [CGFloat]()
        for number in 1...maxNumberOfPhotos {
            switch number {
            case 1,2:
                yOffset.append(0)
            case 3:
                yOffset.append(cellWidth)
            case 4,5,6:
                yOffset.append(largeCellWidth)
            default:
                break
            }
        }
        
        //For each item in a collection view
        for number in 0..<maxNumberOfPhotos {
            let indexPath = IndexPath(item: number, section: 0)
            
            if number == 0 {
                let frame = CGRect(x: xOffset[number], y: yOffset[number], width: largeCellWidth, height: largeCellWidth)

                //Creating attributres for the layout and caching them
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
            } else {
                let frame = CGRect(x: xOffset[number], y: yOffset[number], width: cellWidth, height: cellWidth)

                //Creating attributres for the layout and caching them
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
            }
        }
    }
    
    // Is called to determine which items are visible in the given rect
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        //Loop through the cache and look for items in the rect
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    // The attributes for the item at the indexPath
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
