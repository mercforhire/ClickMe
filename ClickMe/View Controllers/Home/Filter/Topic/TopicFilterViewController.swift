//
//  FilterViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-07.
//

import UIKit
import SwiftRangeSlider

protocol TopicFilterViewControllerDelegate: class {
    func topicFilterPicked(filter: TopicFilterCriteria)
}

struct TopicFilterCriteria {
    var sortType: TopicSortTypes?
    var minPrice: Int = 100
    var maxPrice: Int = 50000
    var minTime: Int = 0
    var maxTime: Int = 23
    var mood: Mood?
    
    func exploreEndpointParams(user: CompleteUser) -> ExploreSchedulesParams {
        var params = ExploreSchedulesParams()
        params.minPrice = minPrice
        params.maxPrice = maxPrice
        params.mood = mood
        params.startTime = minTime
        params.endTime = maxTime
        return params
    }
}

class TopicFilterViewController: BaseViewController {
    var filter: TopicFilterCriteria = TopicFilterCriteria()
    
    @IBOutlet weak var sortCollectionView: UICollectionView!
    @IBOutlet weak var sortCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var sliderControl: RangeSlider!
    @IBOutlet weak var timeControl: TimeOfDaySlider!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    weak var delegate: TopicFilterViewControllerDelegate?
    
    private let kItemPadding = 15
    
    static func create(filter: TopicFilterCriteria, delegate: TopicFilterViewControllerDelegate?) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "TopicFilterViewController") as! TopicFilterViewController
        vc.filter = filter
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
        
        clearButton.roundCorners()
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.delegate = self
        sortCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        sortCollectionView.reloadData()
        
        sliderControl.labelColor = themeManager.themeData!.textLabel.hexColor
        timeControl.labelColor = themeManager.themeData!.textLabel.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        resizeCollectionViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshDisplay()
    }
    
    private func refreshDisplay() {
        sortCollectionView.reloadData()
        sliderControl.lowerValue = Double(filter.minPrice)
        sliderControl.upperValue = Double(filter.maxPrice)
        timeControl.lowerValue = Double(filter.minTime)
        timeControl.upperValue = Double(filter.maxTime)
    }
    
    private func resizeCollectionViews() {
        sortCollectionHeight.constant = sortCollectionView.contentSize.height
    }
    
    @IBAction func xPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func coinSliderChanged(_ sender: RangeSlider) {
        filter.minPrice = Int(sender.lowerValue)
        filter.maxPrice = Int(sender.upperValue)
    }
    
    @IBAction func timeSliderChanged(_ sender: RangeSlider) {
        filter.minTime = Int(sender.lowerValue)
        filter.maxTime = Int(sender.upperValue)
    }
    
    @IBAction func applyPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.topicFilterPicked(filter: filter)
    }
    
    @IBAction func clearPress(_ sender: Any) {
        filter = TopicFilterCriteria()
        refreshDisplay()
        delegate?.topicFilterPicked(filter: filter)
    }
}

extension TopicFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sortCollectionView {
            return TopicSortTypes.count.rawValue
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        cell.roundCorners()
        
        if let sortType = TopicSortTypes(rawValue: indexPath.row) {
            cell.lblTitle.text = sortType.title()
            if filter.sortType == sortType {
                cell.highlight()
            } else {
                cell.unhighlight()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let sortType = TopicSortTypes(rawValue: indexPath.row) {
            if filter.sortType == sortType {
                filter.sortType = nil
            } else {
                filter.sortType = sortType
            }
        }
        collectionView.reloadData()
    }
}

extension TopicFilterViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let title = TopicSortTypes(rawValue: indexPath.row)!.title()
        var size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 40
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}
