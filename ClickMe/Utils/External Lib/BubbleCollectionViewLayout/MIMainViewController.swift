//
//  MIMainViewController.swift
//  SwiftDemo
//
//  Created by mac-0007 on 05/12/17.
//  Copyright © 2017 Jignesh-0007. All rights reserved.
//

import UIKit

class MIMainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MICollectionViewBubbleLayoutDelegate {

    @IBOutlet var collVData:UICollectionView!
    
    let kItemPadding = 15
    var arrData:NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //...
        arrData = ["None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple", "Regular", "Chocolate", "Blueberry", "Devil's Food", "None", "Glazed", "Sugar", "Powdered Sugar", "Chocolate with Sprinkles", "Chocolate", "Maple"]
        
        
        //...UICollectionView setup
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 6.0
        bubbleLayout.minimumInteritemSpacing = 6.0
        bubbleLayout.delegate = self 
        collVData.setCollectionViewLayout(bubbleLayout, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: -
    // MARK: - UICollectionView Delegate & Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indentifier = "MIBubbleCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indentifier, for: indexPath) as! MIBubbleCollectionViewCell
        
        cell.lblTitle.text = arrData![indexPath.row] as? String
        return cell
    }
    
    
    // MARK: -
    // MARK: - MICollectionViewBubbleLayoutDelegate
    
    func collectionView(_ collectionView:UICollectionView, itemSizeAt indexPath:NSIndexPath) -> CGSize
    {
        let title = arrData![indexPath.row] as! NSString
        var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 15)!])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 24
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size;
    }

}
