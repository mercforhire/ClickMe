//
//  SetupPhotoViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-20.
//

import UIKit
import Kingfisher
import AVKit
import PhotosUI
import Mantis

class SetupPhotoViewController: BaseViewController {
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var frames: [UIImageView]!
    @IBOutlet var plusButtons: [UIButton]!
    
    @IBOutlet weak var nextButton: UIButton!
    
    private let defaultImage: UIImage = UIImage()
    private var profileImages: [UIImage]! {
        didSet {
            for index in 0..<profileImages.count {
                if profileImages[index] == defaultImage {
                    if let imageView = getImageView(index: index), let plusButton = getPlusButtons(index: index) {
                        imageView.image = nil
                        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                    }
                } else {
                    if let imageView = getImageView(index: index), let plusButton = getPlusButtons(index: index) {
                        imageView.image = profileImages[index]
                        plusButton.setImage(UIImage(systemName: "minus"), for: .normal)
                    }
                }
            }
        }
    }
    private var imagePicker: ImagePicker!
    
    private func getImageView(index: Int) -> UIImageView? {
        return imageViews.filter { $0.tag == index }.first
        
    }
    
    private func getPlusButtons(index: Int) -> UIButton? {
        return plusButtons.filter { $0.tag == index }.first
        
    }
    
    override func setup() {
        super.setup()
        profileImages = [defaultImage, defaultImage, defaultImage, defaultImage]
        
        for imageView in imageViews {
            imageView.roundCorners(style: .medium)
        }
        
        for plusButton in plusButtons {
            plusButton.roundCorners(style: .completely)
        }
        
        imagePicker = ImagePicker(presentationController: self,
                                  delegate: self)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        
        for imageView in imageViews {
            imageView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        }
        
        for frame in frames {
            frame.tintColor = themeManager.themeData!.defaultBackground.hexColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for index in 0..<(userManager.user?.photos?.count ?? 0) {
            if let photo = userManager.user?.photos?[index],
               let url = URL(string: photo.normalUrl),
               let imageView = getImageView(index: index) {
                imageView.kf.setImage(with: url) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let image):
                        self.profileImages[index] = image.image
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @IBAction private func pickPhoto(_ sender: UIButton) {
        let index = sender.tag
        let currentPhotosCount: Int = userManager.user?.photos?.count ?? 0
        
        if index >= currentPhotosCount {
            
            requestPhotoPermission { [weak self] hasPermission in
                guard let self = self else { return }
                
                if hasPermission {
                    self.getImageOrVideoFromAlbum(sourceView: sender)
                } else {
                    showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
                }
            }
        } else {
            if let avatar = userManager.user?.photos?[index] {
                userManager.deleteProfilePhoto(index: index, deleteThis: avatar) { [weak self] success in
                    guard let self = self else { return }
                    
                    if success {
                        self.profileImages[index] = self.defaultImage
                    }
                }
            }
        }
    }
    
    private func getImageOrVideoFromAlbum( sourceView: UIView) {
        self.imagePicker.present(from: sourceView)
    }
    
    private func showMantis(image: UIImage) {
        var config = Mantis.Config()
        config.cropToolbarConfig.toolbarButtonOptions = [.clockwiseRotate, .reset, .ratio, .alterCropper90Degree];
        
        let cropViewController = Mantis.cropViewController(image: image,
                                                           config: config)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    
    @IBAction func skipPressed(_ sender: Any) {
        userManager.setupManager.skipped(screen: .Photo)
    }
    
    @IBAction private func nextPress(_ sender: Any) {
        if profileImages.first != defaultImage {
            goToNextScreen()
        } else {
            showErrorDialog(error: "Please add at least 1 photo.")
        }
    }
    
    private func goToNextScreen() {
        userManager.setupManager.goToAppropriateSetupView(vc: self)
    }
    
    private func uploadPhoto(photo: UIImage) {
        guard let data = photo.jpeg else { return }
        
        let fileSize = fileSize(forData: data)
        print("File size: \(fileSize)")
        if fileSize > 2.0 {
            showErrorDialog(error: "File size too large, please pick a photo smaller than 2 MB")
            return
        }
        
        userManager.uploadProfilePhoto(data: data) { [weak self] success in
            guard let self = self else { return }
            
            if let replaceIndex: Int = self.profileImages.firstIndex(of: self.defaultImage) {
                self.profileImages[replaceIndex] = photo
            }
        }
    }
}

extension SetupPhotoViewController: ImagePickerDelegate {
    func didSelectImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        showMantis(image: image)
    }
    
    func didSelectVideo(video: PHAsset?) {
        
    }
}

extension SetupPhotoViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        print(transformation);
        dismiss(animated: true, completion: { [weak self] in
            self?.uploadPhoto(photo: cropped)
        })
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
}
