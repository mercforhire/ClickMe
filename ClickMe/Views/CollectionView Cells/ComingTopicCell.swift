//
//  ComingTopicCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-18.
//

import UIKit

class ComingTopicCell: UICollectionViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.roundCorners(style: .medium)
        container.backgroundColor = themeManager.themeData!.indigo.hexColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(data: Schedule) {
        datelabel.text = "\(DateUtil.convert(input: data.startTime, outputFormat: .format11) ?? "")\n\(DateUtil.convert(input: data.startTime, outputFormat: .format8) ?? "") - \(DateUtil.convert(input: data.endTime, outputFormat: .format8) ?? "")"
        categoryImageView.image = data.mood.icon()
        topicLabel.text = data.title
        costLabel.text = "\(data.coin)"
    }
}
