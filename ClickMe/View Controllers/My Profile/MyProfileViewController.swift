//
//  MyProfileViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-15.
//

import UIKit
import Kingfisher

class MyProfileViewController: BaseViewController {
    enum Rows: Int {
        case wallet
        case saved
        case history
        case invite
        case switchMode
        case count
        
        func title() -> String {
            switch self {
            case .wallet:
                return "My Wallet"
            case .saved:
                return "Saved ClickMe"
            case .history:
                return "ClickMe History"
            case .invite:
                return "Invite"
            case .switchMode:
                return "Switch to host"
            default:
                return ""
            }
        }
        
        func icon() -> UIImage {
            switch self {
            case .wallet:
                return UIImage(systemName: "wallet.pass")!
            case .saved:
                return UIImage(systemName: "folder")!
            case .history:
                return UIImage(systemName: "clock.arrow.circlepath")!
            case .invite:
                return UIImage(systemName: "person.badge.plus")!
            case .switchMode:
                return UIImage(systemName: "arrow.2.squarepath")!
            default:
                return UIImage(systemName: "xmark.bin")!
            }
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var screenIDLabel: UITextView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    
    private var selectedAssociation: Association?
    
    override func setup() {
        super.setup()
        
        profileImage.roundCorners(style: .medium)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userManager.fetchUser { [weak self] success in
            if success {
                self?.refreshDisplay()
                self?.showTutorialIfNeeded()
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableview.updateHeaderViewHeight()
    }
    
    @IBAction func likesTapped(_ sender: UITapGestureRecognizer) {
        guard let user = userManager.user, let likes = user.receivedLikesFrom?.count, likes > 0 else { return }
        
        let dialog = LikesDialog()
        dialog.configure(numberOfLikes: likes, showDimOverlay: true, overUIWindow: true)
        dialog.show(inView: view, withDelay: 100)
    }
    
    @IBAction func followingTapped(_ sender: Any) {
        selectedAssociation = .following
        performSegue(withIdentifier: "goToManageFollowers", sender: self)
    }
    
    @IBAction func followersTapped(_ sender: Any) {
        selectedAssociation = .followers
        performSegue(withIdentifier: "goToManageFollowers", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile", let userId = userManager.user?.identifier {
            let vc = segue.destination as! ProfileDetailsViewController
            vc.userId = userId
            vc.viewingMySelf = true
        } else if let vc = segue.destination as? ManageFollowerRootViewController {
            vc.defaultAssociation = selectedAssociation!
            vc.user = userManager.user!.publicUser
        }
    }
    
    private func refreshDisplay() {
        guard let user = userManager.user else { return }
        
        if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
            profileImage.kf.setImage(with: url)
        } else {
            profileImage.image = user.defaultAvatar
        }
        nameLabel.text = user.fullNameAndAge
        jobLabel.text = user.jobDescription
        screenIDLabel.text = "ID#: \(user.screenId)"
        likesCount.text = "\(user.receivedLikesFrom?.count ?? 0)"
        followingCount.text = "\(user.following?.count ?? 0)"
        followersCount.text = "\(user.followers?.count ?? 0)"
    }
    
    func showTutorialIfNeeded() {
        tutorialManager = TutorialManager(viewController: self)
        tutorialManager?.showTutorial()
    }
}

extension MyProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = themeManager.themeData?.textLabel.hexColor
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 20)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "   Account"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuCell", for: indexPath) as? ProfileMenuCell, let row = Rows(rawValue: indexPath.row) else {
            return ProfileMenuCell()
        }
        
        cell.icon.image = row.icon()
        cell.label.text = row.title()
        
        if indexPath.row == Rows.count.rawValue - 1 {
            cell.contentView.removeOnePixelSeparator()
        } else {
            cell.contentView.insertOnePixelSeparator(color: themeManager.themeData!.defaultBackground.hexColor,
                                                     inset: 40,
                                                     position: .bottom)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Rows(rawValue: indexPath.row)
        
        switch row {
        case .wallet:
            performSegue(withIdentifier: "goToWallet", sender: self)
        case .saved:
            performSegue(withIdentifier: "goToSaved", sender: self)
        case .history:
            performSegue(withIdentifier: "goToHistory", sender: self)
        case .invite:
            showErrorDialog(error: "Sorry, feature coming soon.")
        case .switchMode:
            if AgoraManager.shared.inInACall {
                showErrorDialog(error: "Sorry, can't switch mode during middle of a call.")
            } else {
                StoryboardManager.load(storyboard: "Host", animated: true, completion: nil)
            }
        default:
            break
        }
    }
}

extension MyProfileViewController: TutorialSupport {
    func screenName() -> TutorialName {
        return TutorialName.myProfile
    }
    
    func steps() -> [TutorialStep] {
        var tutorialSteps: [TutorialStep] = []
        
        let tableHeaderHeight: CGFloat = 337.0
        let cellHeight: CGFloat = 50.0
        
        let step = TutorialStep(screenName: "\(screenName()) + 1",
                                body: "Your purchased or earned coins are stored here.",
                                pointingDirection: .down,
                                pointPosition: .edge,
                                targetFrame: CGRect(x: tableview.frame.origin.x,
                                                    y: tableHeaderHeight + 20 + tableview.frame.origin.y + cellHeight,
                                                    width: tableview.frame.width,
                                                    height: cellHeight),
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step)
        
        let step2 = TutorialStep(screenName: "\(screenName()) + 2",
                                body: "Want to show us your skills?\nYou can host a ClickMe too! ",
                                pointingDirection: .down,
                                pointPosition: .edge,
                                 targetFrame: CGRect(x: tableview.frame.origin.x,
                                                     y: tableHeaderHeight + 20 + tableview.frame.origin.y + cellHeight * 5,
                                                     width: tableview.frame.width,
                                                     height: cellHeight),
                                showDimOverlay: true,
                                overUIWindow: true)
        tutorialSteps.append(step2)
        
        return tutorialSteps
    }
    
    func stepOpened(stepCount: Int) {
        
    }
}
