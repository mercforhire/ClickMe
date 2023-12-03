//
//  VerifyStep2ViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-28.
//

import UIKit

protocol VerifyCameraViewControllerDelegate: class {
    func verifyComplete()
}

class VerifyCameraViewController: BaseViewController, UINavigationControllerDelegate {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var checkButton: UIButton!
    
    private var cameraView: UIView!
    private let myCamera = UIImagePickerController()
    private var capturedImage: UIImage? {
        didSet {
            guard let capturedImage = capturedImage else { return }
            
            imageView.image = capturedImage
            checkButton.isHidden = false
        }
    }
    weak var delegate: VerifyCameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        button.layer.cornerRadius = button.frame.height / 2
        checkButton.isHidden = true
        cameraView = StoryboardManager.loadViewController(storyboard: "Verify", viewControllerId: "VerifyOverlayViewController")!.view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem"), object:nil, queue:nil, using: { [weak self] _ in
            self?.cameraView.isHidden = true
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem"), object:nil, queue:nil, using: { [weak self] _ in
            self?.cameraView.isHidden = false
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        cameraView.isHidden = false
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera), UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera) != nil {
            // Use front camera and add overlay on it
            myCamera.sourceType = .camera
            myCamera.cameraDevice = .front
            myCamera.delegate = self
            myCamera.showsCameraControls = true
            myCamera.allowsEditing = false
            myCamera.cameraOverlayView = cameraView
            present(myCamera, animated: false, completion: nil)
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary), UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.photoLibrary) != nil {
            // Use front camera and add overlay on it
            myCamera.sourceType = .photoLibrary
            myCamera.delegate = self
            myCamera.allowsEditing = false
            present(myCamera, animated: false, completion: nil)
        } else {
            let ac = UIAlertController(title: "No camera device found.", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            ac.addAction(cancelAction)
            present(ac, animated: true)
        }
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.verifyComplete()
    }
}

extension VerifyCameraViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        myCamera.dismiss(animated: true) { [weak self] in
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            self?.capturedImage = image
        }
    }
}
