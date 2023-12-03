//
//  EditProfileViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-11.
//

import UIKit
import RandomColorSwift

class EditProfileViewController: BaseViewController {
    enum MenuSections: Int {
        case basicInfo
        case aboutMe
        case interests
        case lookingFor
        case count
        
        func title() -> String {
            switch self {
            case .basicInfo:
                return "My Basic Info"
            case .aboutMe:
                return "About Me"
            case .interests:
                return "My Interests"
            case .lookingFor:
                return "Looking for"
            default:
                return ""
            }
        }
    }
    
    enum BasicInfoMenuRows: Int {
        case name
        case gender
        case birthday
        case education
        case job
        case field
        case location
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
            case .job:
                return "Job Title"
            case .field:
                return "Career Field"
            case .location:
                return "Location"
            default:
                return ""
            }
        }
    }
    
    @IBOutlet weak var profilePhotosCollectionView: UICollectionView!
    @IBOutlet weak var profilePhotosCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    private let MaxPhotosCount = 6
    private var photos = ["person",
                          "person.2",
                          "person.3",
                          "person.icloud"]
    
    private func setupUI() {
        profilePhotosCollectionHeight.constant = profilePhotosCollectionView.frame.width
        profilePhotosCollectionView.delegate = self
        profilePhotosCollectionView.dataSource = self
        profilePhotosCollectionView.dragInteractionEnabled = true
        
        container1.layer.borderWidth = 1.0
        container1.layer.borderColor = UIColor.darkGray.cgColor
        container1.layer.cornerRadius = 6.0

        saveButton.roundCorners(corners: .allCorners, radius: 6.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
    }
}

extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MaxPhotosCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePhotoCell", for: indexPath) as! ProfilePhotoCell
        if indexPath.row < photos.count, let photo = UIImage(systemName: photos[indexPath.row]) {
            cell.setImage(image: photo)
            cell.photoImageView.tintColor = randomColor()
        }
        
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 1.0
        return cell
    }
}

extension EditProfileViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
        if indexPath.row < photos.count {
            let photoName = photos[indexPath.row]
            let item = NSItemProvider(object: photoName as NSItemProviderWriting)
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
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
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
            }, completion: { _ in
                coordinator.drop(dropItem.dragItem,
                                 toItemAt: destinationIndexPath)
            })
        }
    }
}

extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MenuSections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MenuSections(rawValue: section)?.title()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch MenuSections(rawValue: section) {
        case .basicInfo:
            return BasicInfoMenuRows.count.rawValue
        case .aboutMe:
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
        
        switch MenuSections(rawValue: indexPath.section) {
        case .basicInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuCell", for: indexPath) as? ProfileMenuCell else {
                return ProfileMenuCell()
            }
            cell.label.text = BasicInfoMenuRows(rawValue: indexPath.row)?.title()
            return cell
            
        case .aboutMe, .interests, .lookingFor:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTextCell", for: indexPath) as? ProfileTextCell else {
                return ProfileTextCell()
            }
            cell.label.text = Lorem.paragraphs(Int.random(in: 1...3))
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch MenuSections(rawValue: indexPath.section) {
        case .aboutMe:
            present(EditTextViewController.createViewController(title: MenuSections.aboutMe.title(),
                                                                        initialText: Lorem.paragraphs(Int.random(in: 1...3)),
                                                                        delegate: self), animated: true, completion: nil)
        case .interests:
            present(EditTextViewController.createViewController(title: MenuSections.interests.title(),
                                                                        initialText: Lorem.paragraphs(Int.random(in: 1...3)),
                                                                        delegate: self), animated: true, completion: nil)
        case .lookingFor:
            present(EditTextViewController.createViewController(title: MenuSections.lookingFor.title(),
                                                                        initialText: Lorem.paragraphs(Int.random(in: 1...3)),
                                                                        delegate: self), animated: true, completion: nil)
        default:
            break
        }
    }
}

extension EditProfileViewController: EditTextViewControllerDelegate {
    func savePressed(text: String) {
        print("Save text: \(text)")
    }
}
