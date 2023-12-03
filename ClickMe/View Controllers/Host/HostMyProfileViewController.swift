//
//  HostMyProfileViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-30.
//

import UIKit
import Kingfisher

class HostMyProfileViewController: BaseViewController {
    enum Rows: Int {
        case wallet
        case history
        case switchMode
        case signOut
        case count
        
        func title() -> String {
            switch self {
            case .wallet:
                return "My Wallet"
            case .history:
                return "ClickMe History"
            case .switchMode:
                return "Switch to guest"
            case .signOut:
                return "Sign Out"
            default:
                return ""
            }
        }
        
        func icon() -> UIImage {
            switch self {
            case .wallet:
                return UIImage(systemName: "wallet.pass")!
            case .history:
                return UIImage(systemName: "clock")!
            case .switchMode:
                return UIImage(systemName: "bell")!
            case .signOut:
                return UIImage(systemName: "power")!
            default:
                return UIImage(systemName: "xmark.bin")!
            }
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
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
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableview.updateHeaderViewHeight()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile", let userId = userManager.user?.identifier {
            let vc = segue.destination as! ProfileDetailsViewController
            vc.userId = userId
            vc.viewingMySelf = true
        } else if let vc = segue.destination as? HistoryViewController {
            vc.host = true
        } else if let user = userManager.user,
                  let vc = segue.destination as? ReviewsRootViewController {
            vc.userId = user.identifier
            vc.userFullName = user.fullName
        }
    }
    
    @IBAction func reviewsTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToMyReviews", sender: self)
    }
    
    @IBAction func ratingsTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToMyReviews", sender: self)
    }
    
    @IBAction func hoursTapped(_ sender: Any) {
        
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
        
        hoursLabel.text = "\(user.totalHostHours)"
        reviewsLabel.text = "\(user.hostSize)"
        ratingLabel.text = user.hostRatingString
    }
}

extension HostMyProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = themeManager.themeData!.textLabel.hexColor
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 20.0)
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
        case .history:
            performSegue(withIdentifier: "goToHistory", sender: self)
        case .switchMode:
            if AgoraManager.shared.inInACall {
                showErrorDialog(error: "Sorry, can't switch mode during middle of a call.")
            } else {
                StoryboardManager.load(storyboard: "Main", animated: true, completion: nil)
            }
        case .signOut:
            if AgoraManager.shared.inInACall {
                showErrorDialog(error: "Sorry, can't log out during middle of a call.")
            } else {
                logout()
            }
        default:
            break
        }
    }
}
