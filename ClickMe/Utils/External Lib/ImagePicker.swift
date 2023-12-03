//
//  ImagePicker.swift
//  MantisExample
//
//  Created by Echo on 11/10/19.
//  Copyright © 2019 Echo. All rights reserved.
//

import UIKit
import AVKit
import PhotosUI

public protocol ImagePickerDelegate: AnyObject {
    func didSelectImage(image: UIImage?)
    func didSelectVideo(video: PHAsset?)
}

open class ImagePicker: NSObject {
    var videoOnly: Bool = false {
        didSet {
            self.pickerController.mediaTypes = [videoOnly ? "public.movie" : "public.image"]
        }
    }
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
    
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = [videoOnly ? "public.movie" : "public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: videoOnly ? "Take video" : "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.handlePopupInBigScreenIfNeeded(sourceView: sourceView, permittedArrowDirections: [.down, .up])

        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerControllerImage(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelectImage(image: image)
    }
    
    private func pickerControllerVideo(_ controller: UIImagePickerController, didSelect video: PHAsset?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelectVideo(video: video)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerControllerImage(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.pickerControllerImage(picker, didSelect: image)
        }
        else if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            self.pickerControllerVideo(picker, didSelect: asset)
        }
        
        return self.pickerControllerImage(picker, didSelect: nil)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
