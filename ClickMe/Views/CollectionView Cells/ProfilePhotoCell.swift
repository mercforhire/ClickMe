//
//  ProfilePhotoCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-11.
//

import UIKit

class ProfilePhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var plusIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    func loadImageFromURL(urlString: String) {
        if let url = URL(string: urlString) {
            photoImageView.kf.setImage(with: url)
            plusIcon.isHidden = true
        } else {
            resetCell()
        }
    }
    
    func resetCell() {
        photoImageView.image = nil
        plusIcon.isHidden = false
    }
}
