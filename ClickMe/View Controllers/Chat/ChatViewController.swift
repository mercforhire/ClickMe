//
//  ChatViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-13.
//

import UIKit
import KeyboardDismisser
import GrowingTextView
import AVFoundation

protocol ItemWithTimeStamp {
    func getTimeStamp() -> Date
}

protocol ChatViewControllerDelegate: class {
    func requestRefreshConversations()
}

class ChatViewController: BaseViewController {
    var talkingTo: ListUser!
    var schedule: Schedule? {
        didSet {
            guard topicLabel != nil, topicContainerHeight != nil else { return }
            
            refreshTopicContainer()
        }
    }
    var intialMessage: String? {
        didSet {
            guard textView != nil else { return }
            
            textView.text = intialMessage ?? ""
        }
    }
    weak var delegate: ChatViewControllerDelegate?
    
    private let topicContainerDefaultHeight: CGFloat = 200
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var topicContainer: UIView!
    @IBOutlet weak var topicContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomBar: NSLayoutConstraint!
    @IBOutlet weak var newMessageButton: UIButton!
    
    private var chatItems: [ItemWithTimeStamp]? {
        didSet {
            tableview.reloadData()
        }
    }
    
    private var selectedProfile: ListUser?
    private var selected: Schedule?
    
    override func setup() {
        super.setup()
        
        title = talkingTo.fullName
        textView.layer.cornerRadius = 6.0
        setUpInitializers()
        sendButton.isEnabled = false
        newMessageButton.roundCorners()
        newMessageButton.addBorder(color: UIColor.darkGray)
        newMessageButton.isHidden = true
        
        if let schedule = schedule  {
            topicLabel.text = schedule.title
            topicContainerHeight.constant = topicContainerDefaultHeight
        } else {
            topicLabel.text = ""
            topicContainerHeight.constant = 0
        }
    }

    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        sendButton.tintColor = themeManager.themeData!.greenSendIcon.hexColor
        tableview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        KeyboardDismisser.shared.detach()
        fetchData { [weak self] success in
            if success {
                self?.delegate?.requestRefreshConversations()
            }
        }
        refreshView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshChat), name: Notifications.RefreshChat, object: nil)
        userManager.talkingWith = talkingTo
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        KeyboardDismisser.shared.attach()
        NotificationCenter.default.removeObserver(self, name: Notifications.RefreshChat, object: nil)
        userManager.talkingWith = nil
    }
    
    @objc func handleRefreshChat(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let userId = userInfo["userId"] as? Int, talkingTo.identifier == userId {
            fetchData { success in
                if success {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                }
            }
        }
    }
    
    func fetchData(complete: @escaping (Bool) -> Void) {
        chatItems == nil ? FullScreenSpinner().show() : nil
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        var freshChatItems: [ItemWithTimeStamp] = []
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.getChatMessage(userId: self.talkingTo.identifier) { result in
                switch result {
                case .success(let res):
                    freshChatItems.append(contentsOf: res)
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
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                    complete(false)
                }
                return
            }
            
            self.api.getActionLog(otherUser: self.talkingTo.identifier) { result in
                switch result {
                case .success(let res):
                    freshChatItems.append(contentsOf: res)
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
            
            freshChatItems = freshChatItems.sorted(by: { left, right in
                return left.getTimeStamp() < right.getTimeStamp()
            })
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                self?.chatItems = freshChatItems
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
                    self?.tableview.scrollToRow(at: IndexPath(row: self?.chatItems?.count ?? 0, section: 0), at: .bottom, animated: false)
                })
                complete(true)
            }
        }
    }
    
    
    private func refreshView() {
        if let blockedUsers = userManager.user?.blockedUsers, blockedUsers.contains(talkingTo.identifier) {
            textView.placeholder = "User blocked"
            textView.isEditable = false
        } else {
            textView.placeholder = "Type a message here"
            textView.isEditable = true
        }
    }
    
    @IBAction func closeTopicPressed(_ sender: Any) {
        schedule = nil
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        addChat()
    }
    
    @IBAction func newMessagePress(_ sender: Any) {
        
    }
    
    private func addChat() {
        guard let message = textView.text, !message.isEmpty else { return }
        
        sendButton.isEnabled = false
        api.saveChatMessage(scheduleId: schedule?.identifier, toUser: talkingTo.identifier, userMessage: message) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let new):
                if self.schedule != nil {
                    self.schedule = nil
                }
                self.chatItems?.append(new)
                self.textView.text = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                    self?.tableview.scrollToRow(at: IndexPath(row: self?.chatItems?.count ?? 0, section: 0), at: .bottom, animated: true)
                })
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else if error.responseCode == 473 {
                    showErrorDialog(error: "Sorry, \(self.talkingTo.shortName) has blocked you.")
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    private func refreshTopicContainer() {
        if let schedule = schedule  {
            topicLabel.text = schedule.title
            topicContainerHeight.constant = topicContainerDefaultHeight
        } else {
            topicLabel.text = ""
            topicContainerHeight.constant = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile", let vc = segue.destination as? ProfileDetailsViewController {
            vc.userId = selectedProfile?.identifier
        } else if segue.identifier == "goToTopic", let vc = segue.destination as? TopicDetailViewController {
            vc.schedule = selected
        } else if segue.identifier == "goToBooking", let vc = segue.destination as? RequestOverviewViewController {
            vc.schedule = selected
        } else if segue.identifier == "goToBookStatus", let vc = segue.destination as? BookStatusViewController {
            vc.schedule = selected
        } else if let vc = segue.destination as? ChatOptionsViewController {
            vc.user = talkingTo
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return UITableView.automaticDimension
      }

      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let headerView = UIView(frame: .zero)
          headerView.isUserInteractionEnabled = false
          return headerView
      }

      func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          let diff = tableView.contentSize.height - tableView.bounds.height
          return diff > 0 ? 0 : -diff
      }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (chatItems?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chatItems = chatItems else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeginningTableViewCell", for: indexPath) as? BeginningTableViewCell else {
                return BeginningTableViewCell()
            }
            return cell
        } else {
            let chatItem = chatItems[indexPath.row - 1]
            if let message = chatItem as? Message {
                if message.chatMessage.fromUser == userManager.user?.identifier {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "RightChatCell", for: indexPath) as? ChatCell else {
                        return ChatCell()
                    }
                    
                    cell.config(data: message, speaker: userManager.user!.toSimpleUser(), clickToOpenProfile: false)
                    cell.delegate = self
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeftChatCell", for: indexPath) as? ChatCell else {
                        return ChatCell()
                    }
                    
                    cell.config(data: message, speaker: message.user, clickToOpenProfile: true)
                    cell.delegate = self
                    return cell
                }
            } else if let log = chatItem as? ActionLog {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookingActionCell", for: indexPath) as? BookingActionCell else {
                    return BookingActionCell()
                }
                
                cell.logLabel.text = log.logDescription()
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let blockedUsers = userManager.user?.blockedUsers, blockedUsers.contains(talkingTo.identifier) {
            return
        }
        
        sendButton.isEnabled = !textView.text.trim().isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
            addChat()
            return false
        }
        return true
    }
}

extension ChatViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatViewController: ChatCellDelegate {
    func profileTapped(user: ListUser) {
        guard user.identifier != userManager.user?.identifier else { return }
        
        selectedProfile = user
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
    
    func topicTapped(schedule: SimpleSchedule) {
        
        FullScreenSpinner().show()
        api.getSchedule(scheduleId: schedule.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let schedule):
                self.selected = schedule
                if schedule.host.identifier == self.userManager.user?.identifier,
                   schedule.booker != nil,
                   schedule.status != .finished {
                    self.performSegue(withIdentifier: "goToBooking", sender: self)
                } else if schedule.booker?.identifier == self.userManager.user?.identifier,
                          schedule.status != .finished {
                    self.performSegue(withIdentifier: "goToBookStatus", sender: self)
                } else {
                    self.performSegue(withIdentifier: "goToTopic", sender: self)
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
}

extension ChatViewController: KeyBoardNotificationDelegate {
    func setUpInitializers() {
        KeyboardNotificationController.sharedKC.registerforKeyBoardNotification(delegate: self)
        addOnTapDismissKeyboard()
    }
    
    func addOnTapDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: - KeyBoardNotificationDelegate
    
    func didKeyBoardAppeared(keyboardHeight: CGFloat) {
        bottomBar.constant = (keyboardHeight == 0) ? 0 : keyboardHeight - (tabBarController?.tabBar.frame.height ?? 49.0)

        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.tableview.scrollToBottom()
        })
    }
}
