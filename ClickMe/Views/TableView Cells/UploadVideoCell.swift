//
//  UploadVideoCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-20.
//

import UIKit
import Kingfisher

enum UploadVideoCellState {
    case empty
    case uploading(Double)
    case ready(String)
}

class UploadVideoCell: UITableViewCell {
    @IBOutlet weak var videoPreview: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var uploadIcon: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var state: UploadVideoCellState = .empty {
        didSet {
            switch state {
            case .empty:
                videoPreview.image = nil
                progressBar.isHidden = true
                progressBar.setProgress(0, animated: false)
                uploadIcon.isHidden = true
                addButton.isHidden = false
                playButton.isHidden = true
                deleteButton.isHidden = true
            case .uploading(let progress):
                videoPreview.image = nil
                progressBar.isHidden = false
                progressBar.setProgress(Float(progress), animated: false)
                uploadIcon.isHidden = false
                addButton.isHidden = true
                playButton.isHidden = true
                deleteButton.isHidden = true
            case .ready(let url):
                loadImageFromURL(urlString: url)
                progressBar.isHidden = true
                progressBar.setProgress(1.0, animated: false)
                uploadIcon.isHidden = true
                addButton.isHidden = true
                playButton.isHidden = false
                deleteButton.isHidden = false
            }
            
            deleteButton.isEnabled = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        videoPreview.roundCorners()
        playButton.roundCorners(style: .completely)
        deleteButton.roundCorners(style: .completely)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadImageFromURL(urlString: String) {
        if let url = URL(string: urlString) {
            videoPreview.kf.setImage(with: url)
        } else {
            videoPreview.image = nil
        }
    }

}
