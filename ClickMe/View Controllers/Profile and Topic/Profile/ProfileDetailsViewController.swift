//
//  ProfileDetailsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-10.
//

import UIKit
import AVKit
import ImageViewer
import Kingfisher

class ProfileDetailsViewController: BaseViewController {
    var userId: Int!
    var viewingMySelf: Bool = false
    
    private let kItemPadding = 20
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var photoSectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var photoPageControl: UIPageControl!
    @IBOutlet weak var roundCornersView: UIView!
    @IBOutlet weak var iAmHostButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var rightSideContainer: UIStackView!
    @IBOutlet weak var interactionButtonContainer: UIView!
    
    @IBOutlet weak var nameViewsContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UITextView!
    
    @IBOutlet weak var jobViewsContainer: UIView!
    @IBOutlet weak var skillIconView: UIImageView!
    @IBOutlet weak var jobLabel: UILabel!
    
    @IBOutlet weak var followViewsContainer: UIView!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var followersNumberLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var birthdayContainer: UIStackView!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    @IBOutlet weak var educationContainer: UIStackView!
    @IBOutlet weak var educationLabel: UILabel!
    
    @IBOutlet weak var schoolContainer: UIStackView!
    @IBOutlet weak var schoolLabel: UILabel!
    
    @IBOutlet weak var hometownContainer: UIStackView!
    @IBOutlet weak var hometownLabel: UILabel!
    
    @IBOutlet weak var locationContainer: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var expertiseLabel: UILabel!
    
    @IBOutlet weak var interestsCollectionView: UICollectionView!
    @IBOutlet weak var interestsCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lookingForLabel: UILabel!
    
    @IBOutlet weak var scheduleHeaderContainer: UIView!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    
    @IBOutlet weak var blockContainer: UIView!
    
    private var user: PublicUser?
    private var schedules: [Schedule]?
    private var selected: Schedule?
    private var selectedAssociation: Association?
    private var showedFollowEachOtherDialog = false
    private var galleryItems: [GalleryItem] {
        guard let photos = user?.photos else { return [] }
        
        var galleryItems: [GalleryItem] = []
        
        for photo in photos {
            guard let url = URL(string: photo.normalUrl) else { continue }
            
            let myFetchImageBlock: FetchImageBlock = { imageCompletion in
                ImageDownloader.default.downloadImage(with: url,
                                                      options: [],
                                                      progressBlock: nil) { result in
                    switch result {
                    case .success(let result):
                        imageCompletion(result.image)
                    default:
                        imageCompletion(nil)
                    }
                }
            }
            
            let itemViewControllerBlock: ItemViewControllerBlock = { index, itemCount, fetchImageBlock, configuration, isInitialController in
                return AnimatedViewController(index: index, itemCount: photos.count, fetchImageBlock: myFetchImageBlock, configuration: configuration, isInitialController: isInitialController)
            }
            
            let galleryItem = GalleryItem.custom(fetchImageBlock: myFetchImageBlock, itemViewControllerBlock: itemViewControllerBlock)
            galleryItems.append(galleryItem)
        }
        
        
        return galleryItems
    }
    
    static func create(userId: Int) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "OthersProfile", viewControllerId: "ProfileDetailsViewController") as! ProfileDetailsViewController
        vc.userId = userId
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    private func refreshView() {
        guard let user = user else { return }
        
        if viewingMySelf {
            title = "My Profile"
            rightSideContainer.isHidden = true
            interactionButtonContainer.isHidden = true
            blockContainer.isHidden = true
        } else {
            title = user.fullName
        }
        if let age = user.age {
            nameLabel.text = "\(user.fullName), \(age)"
        } else {
            nameLabel.text = "\(user.fullName)"
        }
        userIDLabel.text = "ID: \(user.screenId ?? "")"
        skillIconView.image = user.field?.icon()
        
        jobLabel.text = user.jobDescription
        followingNumberLabel.text = "\(user.following?.count ?? 0)"
        followersNumberLabel.text = "\(user.followers?.count ?? 0)"
        ratingLabel.text = user.ratingString
        
        if user.birthday != nil && user.isBirthdayPublic {
            birthdayLabel.text = user.birthdayString
        } else {
            birthdayContainer.isHidden = true
        }
        
        if !user.degree.isEmpty {
            educationLabel.text = user.degree
        } else {
            educationContainer.isHidden = true
        }
        
        if !user.school.isEmpty {
            schoolLabel.text = user.school
        } else {
            schoolContainer.isHidden = true
        }
        
        if !user.school.isEmpty {
            schoolLabel.text = user.school
        } else {
            schoolContainer.isHidden = true
        }
        
        if let hometown = user.hometown?.locationString {
            hometownLabel.text = hometown
        } else {
            hometownContainer.isHidden = true
        }
        
        if let locationString = user.liveAt?.locationString {
            locationLabel.text = locationString
        } else {
            locationContainer.isHidden = true
        }
        
        let emptyText = "(Empty)"
        aboutLabel.text = user.aboutMe.isEmpty ? emptyText : user.aboutMe
        expertiseLabel.text = (user.expertise?.isEmpty ?? true) ? emptyText : user.expertise
        lookingForLabel.text = user.lookingFor.isEmpty ? emptyText : user.lookingFor
        
        photoPageControl.numberOfPages = user.photos?.count ?? 0
        
        if !viewingMySelf, let schedules = schedules, !schedules.isEmpty {
            scheduleHeaderContainer.isHidden = false
            scheduleCollectionView.isHidden = false
        } else {
            iAmHostButton.isHidden = true
            scheduleHeaderContainer.isHidden = true
            scheduleCollectionView.isHidden = true
        }
        
        cameraButton.isHidden = user.videoURL?.isEmpty ?? true
        refreshActionButton()
        
        photoSectionHeight.constant = view.frame.height - nameViewsContainer.frame.height - jobViewsContainer.frame.height - followViewsContainer.frame.height - 60
        
        scrollView.isHidden = false
        photosCollectionView.reloadData()
        scheduleCollectionView.reloadData()
        interestsCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.interestsCollectionViewHeight.constant = self?.interestsCollectionView.contentSize.height ?? 0.0
        })
    }
    
    override func setup() {
        super.setup()
        
        photoSectionHeight.constant = view.frame.height * 0.6
        roundCornersView.layer.cornerRadius = 20.0
        cameraButton.roundCorners(style: .completely)
        followButton.roundCorners(style: .completely)
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 5.0
        bubbleLayout.minimumInteritemSpacing = 5.0
        bubbleLayout.delegate = self
        interestsCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        scrollView.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        photosCollectionView.reloadData()
        scheduleCollectionView.reloadData()
        interestsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    private func fetchData() {
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.api.getUserSchedules(userId: self.userId) { [weak self]  result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.schedules = response
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                self.refreshView()
            }
        }
    }
    
    @IBAction private func followButtonPressed(_ sender: Any) {
        if let followingList = userManager.user?.following, followingList.contains(userId) {
            userManager.unfollowUser(userId: userId, completion: modifyActionCompletionHandler)
        } else {
            userManager.followUser(userId: userId, completion: modifyActionCompletionHandler)
        }
    }
    
    @IBAction private func iAmHostPressed(_ sender: Any) {
        scrollView.scrollToView(view: scheduleHeaderContainer, animated: true)
    }
    
    @IBAction private func videoPressed(_ sender: Any) {
        guard let urlString = user?.videoURL else { return }
        
        playVideo(urlString: urlString)
    }
    
    
    @IBAction func followingTapped(_ sender: Any) {
        selectedAssociation = .following
        performSegue(withIdentifier: "goToFollowers", sender: self)
    }
    
    
    @IBAction func followersTapped(_ sender: Any) {
        selectedAssociation = .followers
        performSegue(withIdentifier: "goToFollowers", sender: self)
    }
    
    @IBAction func ratingTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToReview", sender: self)
    }
    
    @IBAction private func donatePress(_ sender: Any) {
        let vc = DonateViewController.createViewController(donateTo: user!.toSimpleUser())
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func chatButton(_ sender: UIButton) {
        guard let user = user else { return }
        
        NotificationCenter.default.post(name: Notifications.SwitchToChat,
                                        object: nil,
                                        userInfo: ["user": user.toSimpleUser()])
    }
    
    @IBAction func reportPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Report / Block this person?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "goToReport", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { [weak self] _ in
            guard let self = self, let user = self.user else { return }
            
            self.userManager.blockUser(userId: user.identifier) { [weak self] success in
                guard let self = self else { return }
                
                self.backPressed()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let centerCell = photosCollectionView.centerMostCell else { return }
        
        let indexPath = photosCollectionView.indexPath(for: centerCell)
        photoPageControl.currentPage = indexPath?.row ?? 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSchedule" {
            let viewController = segue.destination as! ScheduleViewController
            viewController.host = user
        } else if let vc = segue.destination as? BookStatusViewController {
            vc.schedule = selected
        } else if let vc = segue.destination as? ReviewsRootViewController {
            vc.userId = userId
            vc.userFullName = user?.fullName
        } else if let vc = segue.destination as? ManageFollowerRootViewController {
            vc.defaultAssociation = selectedAssociation!
            vc.user = user
        } else if let vc = segue.destination as? ReportMenuViewController,
                  let user = user {
            vc.userId = user.identifier
        }
    }
    
    
    private func refreshActionButton() {
        guard let myself = userManager.user, let user = user else { return }
        
        if let followingList = userManager.user?.following,
           followingList.contains(user.identifier),
           user.following?.contains(myself.identifier) ?? false {
            followButton.setImage(UIImage(systemName: "arrow.right.arrow.left")!, for: .normal)
        } else if let followingList = userManager.user?.following, followingList.contains(user.identifier) {
            followButton.setImage(UIImage(systemName: "checkmark")!, for: .normal)
        } else {
            followButton.setImage(UIImage(systemName: "plus")!, for: .normal)
        }
    }
    
    private func fetchUser(completion: @escaping (Bool) -> Void) {
        api.getUser(userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.user = response
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    private func modifyActionCompletionHandler(_ success: Bool) {
        if success {
            self.fetchUser { [weak self] success in
                guard let self = self else { return }
                
                self.refreshView()
                
                if !self.showedFollowEachOtherDialog,
                   let user = self.user,
                   let myself = self.userManager.user,
                   let followingList = self.userManager.user?.following,
                   followingList.contains(user.identifier),
                   user.following?.contains(myself.identifier) ?? false {
                    
                    let dialog = FollowEachOtherDialog()
                    dialog.configure(showDimOverlay: true, overUIWindow: true)
                    dialog.show(inView: self.view, withDelay: 100)
                    self.showedFollowEachOtherDialog = true
                }
            }
        }
    }
    
    private func likeActionCompletionHandler(_ success: Bool) {
        if success {
            self.fetchUser { [weak self] success in
                guard let self = self else { return }
                
                self.refreshView()
            }
        }
    }
    
    
    private func showGalleryImageViewer(startIndex: Int) {
        var config = GalleryConfiguration()
        config.append(.closeButtonMode(.builtIn))
        config.append(.seeAllCloseButtonMode(.none))
        config.append(.deleteButtonMode(.none))
        let gVC = GalleryViewController(startIndex: startIndex, itemsDataSource: self, configuration: config)
        presentImageGallery(gVC)
    }
}

extension ProfileDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == photosCollectionView {
            return photosCollectionView.frame.size
        } else if collectionView == scheduleCollectionView {
            return .init(width: scheduleCollectionView.frame.height * 1.12, height: scheduleCollectionView.frame.height)
        } else if collectionView == interestsCollectionView {
            return self.collectionView(collectionView, itemSizeAt: indexPath as NSIndexPath)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == photosCollectionView {
            return 0
        } else if collectionView == scheduleCollectionView {
            return 10
        } else if collectionView == interestsCollectionView {
            return 5
        }
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == photosCollectionView {
            return 0
        } else if collectionView == scheduleCollectionView {
            return 10
        } else if collectionView == interestsCollectionView {
            return 5
        }
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else {
            return 0
        }
        
        if collectionView == photosCollectionView {
            return max(1, user.photos?.count ?? 0)
        } else if collectionView == scheduleCollectionView {
            return schedules?.count ?? 0
        } else if collectionView == interestsCollectionView {
            return max(1, user.interests?.count ?? 0)
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let user = user else {
            return UICollectionViewCell()
        }
        
        if collectionView == photosCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            
            if !(user.photos?.isEmpty ?? true), let photoURL = user.photos?[indexPath.row].normalUrl {
                cell.loadImageFromURL(urlString: photoURL)
            } else {
                cell.imageView.image = user.defaultAvatar
            }
            return cell
        } else if collectionView == scheduleCollectionView {
            guard let schedules = schedules else {
                return ComingTopicCell()
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComingTopicCell", for: indexPath) as! ComingTopicCell
            cell.config(data: schedules[indexPath.row])
            return cell
        } else if collectionView == interestsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
            let interest = user.interests?[indexPath.row].capitalizingFirstLetter()
            cell.lblTitle.text = interest ?? "(Empty)"
            cell.roundCorners()
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photosCollectionView {
            if !(user?.photos?.isEmpty ?? true) {
                showGalleryImageViewer(startIndex: indexPath.row)
            }
        } else if collectionView == scheduleCollectionView, let schedules = schedules {
            NotificationCenter.default.post(name: Notifications.SwitchToSchedule, object: nil, userInfo: ["schedule": schedules[indexPath.row]])
        }
    }
}

extension ProfileDetailsViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        guard let user = user else { return CGSize.zero }
        
        let interest = user.interests?[indexPath.row].capitalizingFirstLetter() ?? "(Empty)"
        var size = interest.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 40
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}

extension ProfileDetailsViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return galleryItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return galleryItems[index]
    }
}

// Extend ImageBaseController so we get all the functionality for free
class AnimatedViewController: ItemBaseController<UIImageView> {
    
}
