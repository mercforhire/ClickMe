//
//  ImageCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-10.
//

import UIKit
import Kingfisher
import ImageViewer

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    weak var presentingVC: UIViewController?
    
    private var galleryItems: [GalleryItem] {
        let image = imageView.image!
        let galleryItem = GalleryItem.image { $0(image) }
        return [galleryItem]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(showGalleryImageViewer))
        imageView.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func loadImageFromURL(urlString: String, presentingVC: UIViewController? = nil) {
        self.presentingVC = presentingVC
        imageView.isUserInteractionEnabled = presentingVC != nil
        if let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        }
    }
    
    @objc private func showGalleryImageViewer() {
        guard let presentingVC = presentingVC, imageView.image != nil  else { return }
        
        var config = GalleryConfiguration()
        config.append(.closeButtonMode(.builtIn))
        config.append(.seeAllCloseButtonMode(.none))
        config.append(.deleteButtonMode(.none))
        let gVC = GalleryViewController(startIndex: 0, itemsDataSource: self, configuration: config)
        presentingVC.presentImageGallery(gVC)
    }
}

extension ImageCell: GalleryItemsDataSource {
    func itemCount() -> Int {
        return galleryItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return galleryItems[index]
    }
}
