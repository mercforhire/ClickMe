//
//  EditProfileViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-11.
//

import UIKit
import AVKit
import PhotosUI
import Mantis

class EditProfileViewController: BaseViewController {
    enum MenuSections: Int {
        case myVideo
        case basicInfo
        case aboutMe
        case expertise
        case interests
        case lookingFor
        case count
        
        func title() -> String {
            switch self {
            case .myVideo:
                return "  My Video"
                
            case .basicInfo:
                return "  My Basic Info"
                
            case .aboutMe:
                return "  About Me"
                
            case .expertise:
                return "  Expertise"
                
            case .interests:
                return "  My Interests"
                
            case .lookingFor:
                return "  Looking for"
                
            default:
                return ""
            }
        }
    }
    
    enum BasicInfoMenuRows: Int {
        case name
        case gender
        case birthday
        case divider1
        case education
        case school
        case divider2
        case job
        case company
        case field
        case divider3
        case location
        case divider4
        case seekRomance
        case count
        
        func title() -> String {
            switch self {
            case .name:
                return "Name"
                
            case .gender:
                return "Gender"
                
            case .birthday:
                return "Birthday"
                
            case .education:
                return "Education"
                
            case .school:
                return "School"
                
            case .job:
                return "Job Title"
                
            case .company:
                return "Company"
                
            case .field:
                return "Field"
                
            case .location:
                return "Location"
                
            case .seekRomance:
                return "Seeking romance"
                
            default:
                return "DIVIDER"
            }
        }
    }
    
    @IBOutlet weak var profilePhotosCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var container1: UIView!
    
    private let MaxPhotosCount = 6
    private var photos: [Photo] = []
    private var videoPreview: UIImage?
    private var videoCellState: UploadVideoCellState = .empty
    private var imagePicker: ImagePicker!
    
    override func setup() {
        super.setup()
        
        profilePhotosCollectionView.delegate = self
        profilePhotosCollectionView.dataSource = self
        profilePhotosCollectionView.dragInteractionEnabled = true
        
        container1.layer.borderWidth = 1.0
        container1.layer.borderColor = UIColor.darkGray.cgColor
        container1.layer.cornerRadius = 6.0
        
        tableView.tableHeaderView?.frame.size = .init(width: view.frame.width, height: view.frame.width + 55)
        
        imagePicker = ImagePicker(presentationController: self,
                                  delegate: self)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = themeManager.themeData!.navBarTheme.backgroundColor.hexColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.themeData!.navBarTheme.textColor.hexColor]
        
        userManager.fetchUser { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.refreshView()
            }
        }
    }
    
    private func showPhotoDeleteConfirmation(index: Int) {
        guard index < photos.count else { return }
        
        let alert = UIAlertController(title: "Are you sure you want to delete this photo?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            let deleteThis = self.photos[index]
            
            self.userManager.deleteProfilePhoto(index: index, deleteThis: deleteThis) { success in
                if success {
                    self.photos.remove(at: index)
                    self.profilePhotosCollectionView.reloadData()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showPhotoPicker() {
        requestPhotoPermission { [weak self] hasPermission in
            guard let self = self else { return }
            
            if hasPermission {
                self.getImageOrVideoFromAlbum(videoOnly: false)
            } else {
                showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
            }
        }
    }
    
    private func getImageOrVideoFromAlbum(videoOnly: Bool) {
        self.imagePicker.videoOnly = videoOnly
        self.imagePicker.present(from: profilePhotosCollectionView)
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
    
    @objc private func uploadVideoPress() {
        requestPhotoPermission { [weak self] hasPermission in
            guard let self = self else { return }
            
            if hasPermission {
                self.getImageOrVideoFromAlbum(videoOnly: true)
            } else {
                showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
            }
        }
    }
    
    @objc private func playVideoPress() {
        guard let urlString = userManager.user?.videoURL else { return }
        
        playVideo(urlString: urlString)
    }
    
    @objc private func deleteVideoPress(sender: UIButton) {
        sender.isEnabled = false
        userManager.deleteProfileVideo { success in
            if success {
                self.videoCellState = .empty
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: MenuSections.myVideo.rawValue)], with: .none)
            } else {
                sender.isEnabled = true
            }
        }
    }
    
    @objc private func seekRomanceChanged(sender: UISwitch) {
        var updateForm = UpdateUserParams()
        updateForm.seekingRomance = sender.isOn
        userManager.updateUser(params: updateForm) { success in
            // reverse the change if network failure
            if !success {
                sender.isOn = !sender.isOn
            }
        }
    }
    
    private func openEditText(windowTitle: String, initialText: String, completion: @escaping (String) -> Void) {
        let vc = EditTextViewController.createViewController(title: windowTitle,
                                                             initialText: initialText,
                                                             completion: completion)
        present(vc, animated: true, completion: nil)
    }
    
    private func swapPhotoPositions(source: Int, destination: Int) {
        userManager.swapProfilePhotos(source: source, destination: destination) { [weak self] success in
            guard let self = self else { return }
            
            // reverse the change if network failure
            if !success {
                self.profilePhotosCollectionView.performBatchUpdates({
                    self.photos.swapAt(source, destination)
                    self.profilePhotosCollectionView.reloadData()
                }, completion: nil)
            } else {
                self.refreshView()
            }
        }
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
            
            if success {
                self.refreshView()
            }
        }
    }
    
    private func uploadVideo(video: PHAsset) {
        guard let thumb = video.getAssetThumbnail() else { return }
        FullScreenSpinner().show()
        PHAsset.getURL(asset: video) { [weak self] url in
            guard let self = self, let fileURL = url else { return }
            
            FullScreenSpinner().hide()
            
            let fileSize = fileSize(forURL: fileURL)
            print("File size: \(fileSize)")
            if fileSize > 20.0 {
                showErrorDialog(error: "File size too large, please pick a video smaller than 20 MB")
            } else {
                self.userManager.uploadProfileVideo(fileURL: fileURL, thumbnailImage: thumb) { [weak self] progress in
                    guard let self = self else { return }
                    
                    self.videoCellState = .uploading(progress.rounded(toPlaces: 1))
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: MenuSections.myVideo.rawValue)], with: .none)
                } completion: { [weak self] success in
                    guard let self = self else { return }
                    
                    if success {
                        self.videoPreview = video.getAssetThumbnail()
                        self.videoCellState = .ready(self.userManager.user?.videoThumbnailUrl ?? "")
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: MenuSections.myVideo.rawValue)], with: .automatic)
                    } else {
                        self.videoCellState = .empty
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: MenuSections.myVideo.rawValue)], with: .none)
                    }
                }
            }
        }
    }
    
    private func refreshView() {
        photos.removeAll()
        photos.append(contentsOf: userManager.user?.photos ?? [])
        profilePhotosCollectionView.reloadData()
        
        videoCellState = (userManager.user?.videoURL?.isEmpty ?? true) ? .empty : .ready(userManager.user?.videoThumbnailUrl ?? "")
        tableView.reloadData()
    }
}

extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MaxPhotosCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePhotoCell", for: indexPath) as! ProfilePhotoCell
        if indexPath.row < photos.count {
            let photo = photos[indexPath.row]
            cell.loadImageFromURL(urlString: photo.smallUrl)
        } else {
            cell.resetCell()
        }

        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < photos.count {
            showPhotoDeleteConfirmation(index: indexPath.row)
        } else {
            showPhotoPicker()
        }
    }
}

extension EditProfileViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
        if indexPath.row < photos.count {
            let photoId = "\(photos[indexPath.row].identifier)"
            let item = NSItemProvider(object: photoId as NSItemProviderWriting)
            let dragItem = UIDragItem(itemProvider: item)
            return [dragItem]
        }
        
        return []
    }
}

extension EditProfileViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath, destinationIndexPath.row < photos.count else {
            return
        }
        
        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else {
                return
            }
            
            collectionView.performBatchUpdates({
                photos.swapAt(sourceIndexPath.row, destinationIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: { [weak self] _ in
                coordinator.drop(dropItem.dragItem,
                                 toItemAt: destinationIndexPath)
                self?.swapPhotoPositions(source: sourceIndexPath.row, destination: destinationIndexPath.row)
            })
        }
    }
}

extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MenuSections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = themeManager.themeData!.textLabel.hexColor
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 22.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MenuSections(rawValue: section)?.title()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch MenuSections(rawValue: section) {
        case .myVideo:
            return 1
            
        case .basicInfo:
            return BasicInfoMenuRows.count.rawValue
            
        case .aboutMe:
            return 1
        
        case .expertise:
            return 1
            
        case .interests:
            return 1
            
        case .lookingFor:
            return 1
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = userManager.user else {
            return UITableViewCell()
        }
        
        switch MenuSections(rawValue: indexPath.section) {
        case .myVideo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadVideoCell", for: indexPath) as? UploadVideoCell else {
                return UploadVideoCell()
            }
            cell.addButton.addTarget(self, action: #selector(uploadVideoPress), for: .touchUpInside)
            cell.playButton.addTarget(self, action: #selector(playVideoPress), for: .touchUpInside)
            cell.deleteButton.addTarget(self, action: #selector(deleteVideoPress), for: .touchUpInside)
            cell.state = videoCellState
            return cell
        case .basicInfo:
            let row = BasicInfoMenuRows(rawValue: indexPath.row)!
            let title = row.title()
            
            if title == "DIVIDER" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DIVIDERCELL", for: indexPath)
                cell.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
                cell.contentView.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
                return cell
            } else {
                switch row {
                case .seekRomance:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSwitchViewCell", for: indexPath) as? ProfileSwitchViewCell else {
                        return ProfileSwitchViewCell()
                    }
                    cell.label.text = BasicInfoMenuRows(rawValue: indexPath.row)?.title()
                    cell.toggle.isOn = userManager.user?.seekingRomance ?? false
                    cell.toggle.addTarget(self, action: #selector(seekRomanceChanged), for: .valueChanged)
                    cell.insertOnePixelSeparator(color: themeManager.themeData!.defaultBackground.hexColor,
                                                 inset: 40,
                                                 position: .bottom)
                    return cell
                default:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuCell", for: indexPath) as? ProfileMenuCell else {
                        return ProfileMenuCell()
                    }
                    cell.label.text = BasicInfoMenuRows(rawValue: indexPath.row)?.title()
                    cell.insertOnePixelSeparator(color: themeManager.themeData!.defaultBackground.hexColor,
                                                 inset: 40,
                                                 position: .bottom)
                    return cell
                }
            }
            
        case .aboutMe:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTextCell", for: indexPath) as? ProfileTextCell else {
                return ProfileTextCell()
            }
            cell.label.text = user.aboutMe.isEmpty ? "(Empty)" : user.aboutMe
            return cell
        
        case .expertise:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTextCell", for: indexPath) as? ProfileTextCell else {
                return ProfileTextCell()
            }
            cell.label.text = user.expertise?.isEmpty ?? true ? "(Empty)" : user.expertise
            return cell
            
        case .interests:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTextCell", for: indexPath) as? ProfileTextCell else {
                return ProfileTextCell()
            }
            cell.label.text = user.interestsString.isEmpty ? "(Empty)" : user.interestsString
            return cell
            
        case .lookingFor:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTextCell", for: indexPath) as? ProfileTextCell else {
                return ProfileTextCell()
            }
            cell.label.text = user.lookingFor.isEmpty ? "(Empty)" : user.lookingFor
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch MenuSections(rawValue: indexPath.section) {
        case .basicInfo:
            let title = BasicInfoMenuRows(rawValue: indexPath.row)!.title()
            if title == "DIVIDER" {
                return 20.0
            }
        default:
            break
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch MenuSections(rawValue: indexPath.section) {
        case .basicInfo:
            switch BasicInfoMenuRows(rawValue: indexPath.row) {
            case .name:
                performSegue(withIdentifier: "goToEditName", sender: self)
                
            case .gender:
                performSegue(withIdentifier: "goToEditGender", sender: self)
                
            case .birthday:
                performSegue(withIdentifier: "goToBirthday", sender: self)
                
            case .education:
                performSegue(withIdentifier: "goToEducation", sender: self)
                
            case .school:
                performSegue(withIdentifier: "goToEducation", sender: self)
                
            case .job:
                performSegue(withIdentifier: "goToJob", sender: self)
                
            case .company:
                performSegue(withIdentifier: "goToJob", sender: self)
                
            case .field:
                performSegue(withIdentifier: "goToField", sender: self)
                
            case .location:
                performSegue(withIdentifier: "goToLocation", sender: self)
                
            default:
                break
            }
        
        case .aboutMe:
            openEditText(windowTitle: MenuSections.aboutMe.title(), initialText: userManager.user?.aboutMe ?? "") { [weak self] text in
                guard let self = self else { return }
                
                var updateForm = UpdateUserParams()
                updateForm.aboutMe = text
                self.userManager.updateUser(params: updateForm) { [weak self] success in
                    guard let self = self else { return }
                    
                    if success {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
            
        case .expertise:
            openEditText(windowTitle: MenuSections.expertise.title(), initialText: userManager.user?.expertise ?? "") { [weak self] text in
                guard let self = self else { return }
                
                var updateForm = UpdateUserParams()
                updateForm.expertise = text
                self.userManager.updateUser(params: updateForm) { [weak self] success in
                    guard let self = self else { return }
                    
                    if success {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
            
        case .interests:
            performSegue(withIdentifier: "goToInterests", sender: self)
            
        case .lookingFor:
            openEditText(windowTitle: MenuSections.lookingFor.title(), initialText: userManager.user?.lookingFor ?? "") { [weak self] text in
                guard let self = self else { return }
                
                var updateForm = UpdateUserParams()
                updateForm.lookingFor = text
                self.userManager.updateUser(params: updateForm) { [weak self] success in
                    guard let self = self else { return }
                    
                    if success {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        default:
            break
        }
    }
}

extension EditProfileViewController: ImagePickerDelegate {
    func didSelectImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        showMantis(image: image)
    }
    
    func didSelectVideo(video: PHAsset?) {
        guard let video = video else { return }
        
        dismiss(animated: true, completion: { [weak self] in
            self?.uploadVideo(video: video)
        })
    }
}

extension EditProfileViewController: CropViewControllerDelegate {
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
