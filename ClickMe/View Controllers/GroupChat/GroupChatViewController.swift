//
//  GroupChatViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-24.
//

import UIKit

class GroupChatViewController: BaseViewController {
    var room: GroupChatRoom!
    
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var sideConstraint: NSLayoutConstraint!
    @IBOutlet weak var dismissSideBarButton: UIButton!
    @IBOutlet weak var categoryButton: ThemeRoundedButton!
    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var logButtonContainer: UIView!
    @IBOutlet weak var logButton: ThemeRoundedButton!
    
    @IBOutlet weak var speakersCollectionView: UICollectionView!
    @IBOutlet weak var guestsCollectionView: UICollectionView!
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var addSpeakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    
    
    private let speakerView = SpeakerView.fromNib()! as! SpeakerView
    private var setupCollectionView = false
    private var sidelogOpen: Bool = false {
        didSet {
            if sidelogOpen {
                self.sideConstraint.constant = self.logTableView.frame.width
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                }, completion: { [weak self] finished in
                    self?.dismissSideBarButton.isHidden = false
                    self?.logTableView.scrollToBottom(animated: false)
                })
            } else {
                self.sideConstraint.constant = 0.0
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                }, completion: { [weak self] finished in
                    self?.dismissSideBarButton.isHidden = true
                })
            }
        }
    }
    private var muted: Bool = true {
        didSet {
            let icon = UIImage(systemName: muted ? "mic.slash.fill" : "mic.fill")
            muteButton.setImage(icon, for: .normal)
        }
    }
    
    static func create(room: GroupChatRoom) -> GroupChatViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "GroupChat", viewControllerId: "GroupChatViewController") as! GroupChatViewController
        vc.room = room
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    override func setup() {
        super.setup()
        
        categoryButton.addBorder()
        avatarContainer.backgroundColor = .clear
        avatarContainer.fill(with: speakerView)
        dismissSideBarButton.isHidden = true
        donateButton.roundCorners(style: .completely)
        donateButton.layer.shadowColor = UIColor.black.cgColor
        donateButton.layer.shadowOpacity = 0.1
        donateButton.layer.shadowOffset = .init(width: 0, height: 3)
        donateButton.layer.shadowRadius = 2
        
        addSpeakerButton.roundCorners(style: .completely)
        addSpeakerButton.layer.shadowColor = UIColor.black.cgColor
        addSpeakerButton.layer.shadowOpacity = 0.2
        addSpeakerButton.layer.shadowOffset = .init(width: 0, height: 3)
        addSpeakerButton.layer.shadowRadius = 3
        
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOpacity = 0.2
        bottomBar.layer.shadowOffset = .init(width: 0, height: -3)
        bottomBar.layer.shadowRadius = 3
        
        muteButton.roundCorners(style: .completely)
        muteButton.layer.shadowColor = UIColor.black.cgColor
        muteButton.layer.shadowOpacity = 0.2
        muteButton.layer.shadowOffset = .init(width: 0, height: 3)
        muteButton.layer.shadowRadius = 3
        
        logButton.setTitle("", for: .normal)
        logButton.addBorder()
        muted = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        speakerView.config(data: room.host, order: 1)
        
        categoryButton.setImage(room.mood.icon(), for: .normal)
        categoryButton.setTitle(" \(room.mood.rawValue)", for: .normal)
        titleLabel.text = room.title
        
        if room.log.isEmpty {
            logButtonContainer.isHidden = true
        } else {
            logButtonContainer.isHidden = false
            logButton.setTitle(room.log.last, for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !setupCollectionView {
            setupSpeakersCollectionView()
            setupGuestsCollectionView()
            
            setupCollectionView = true
        }
    }
    
    @IBAction func leavePress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logButtonPress(_ sender: Any) {
        sidelogOpen = true
    }
    
    @IBAction func dismissLogPress(_ sender: Any) {
        sidelogOpen = false
    }
    
    @IBAction func addSpeakerPress(_ sender: Any) {
        let vc = GroupManageViewController.create(maximumSpeakersCount: 9, initialSpeakers: room.speakers, initialGuests: room.guests, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func micPress(_ sender: Any) {
        muted = !muted
    }
    
    private func setupSpeakersCollectionView() {
        let leftRightContentInset: CGFloat = 0
        let itemSpace: CGFloat = 0
        let itemsPerRow: CGFloat = 3
        
        let flowlayout = UICollectionViewFlowLayout()
        let cellWidth: CGFloat = (speakersCollectionView.frame.width - leftRightContentInset * 2 - (itemsPerRow - 1) * itemSpace) / itemsPerRow
        flowlayout.itemSize = .init(width: cellWidth, height: cellWidth)
        flowlayout.scrollDirection = .vertical
        flowlayout.minimumLineSpacing = itemSpace
        flowlayout.minimumInteritemSpacing = itemSpace
        flowlayout.sectionInset = .init(top: 0, left: leftRightContentInset, bottom: 0, right: leftRightContentInset)
        speakersCollectionView.setCollectionViewLayout(flowlayout, animated: false)
    }
    
    private func setupGuestsCollectionView() {
        let leftRightContentInset: CGFloat = 0
        let itemSpace: CGFloat = 0
        let itemsPerRow: CGFloat = 4
        
        let flowlayout = UICollectionViewFlowLayout()
        let cellWidth: CGFloat = (guestsCollectionView.frame.width - leftRightContentInset * 2 - (itemsPerRow - 1) * itemSpace) / itemsPerRow
        flowlayout.itemSize = .init(width: cellWidth, height: cellWidth * 7/6)
        flowlayout.scrollDirection = .vertical
        flowlayout.minimumLineSpacing = itemSpace
        flowlayout.minimumInteritemSpacing = itemSpace
        flowlayout.sectionInset = .init(top: 0, left: leftRightContentInset, bottom: 0, right: leftRightContentInset)
        guestsCollectionView.setCollectionViewLayout(flowlayout, animated: false)
    }
}

extension GroupChatViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == speakersCollectionView {
            return 9
        } else if collectionView == guestsCollectionView {
            return room.guests.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomSpeakerCell", for: indexPath) as! RoomSpeakerCell
        
        if collectionView == speakersCollectionView {
            if indexPath.row < room.speakers.count {
                let speaker = room.speakers[indexPath.row]
                cell.config(data: speaker, order: indexPath.row + 1)
            } else {
                cell.config(data: nil, order: indexPath.row + 1)
            }
        } else  if collectionView == guestsCollectionView {
            let guest = room.guests[indexPath.row]
            cell.config(data: guest, order: nil)
        }
        return cell
    }
}

extension GroupChatViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room.log.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatLogCell", for: indexPath) as? GroupChatLogCell else {
            return GroupChatLogCell()
        }
        cell.logLabel.text = room.log[indexPath.row]
        return cell
    }
}

extension GroupChatViewController: GroupManageViewControllerDelegate {
    func rearrangedUsers(speakers: [ListUser], guests: [ListUser]) {
        room.speakers = speakers
        room.guests = guests
        speakersCollectionView.reloadData()
        guestsCollectionView.reloadData()
    }
}
