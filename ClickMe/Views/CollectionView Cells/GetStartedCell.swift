//
//  GetStartedCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit

class GetStartedCell: UICollectionViewCell {
    @IBOutlet weak var instructionImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(data: GetStartedSteps) {
        instructionImageView.image = data.image()
        headerLabel.text = data.title()
        textLabel.text = data.body()
    }
}
