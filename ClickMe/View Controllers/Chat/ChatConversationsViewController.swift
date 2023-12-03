//
//  ChatConversationsViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import UIKit
import SwipeCellKit
import CRRefresh

enum ChatListType {
    case normal
    case archive
}

class ChatConversationsViewController: BaseViewController {
    var mode: ChatListType = .normal
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    private var conversations: [Message]?
    private var displaying: [Message] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    private var selectedUser: ListUser?
    private var selectedSchedule: Schedule?
    private var initialMessage: String?
    private var delayTimer = DelayedSearchTimer()
    
    override func setup() {
        super.setup()
        
        tableview.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchData(complete: { success in
                self?.tableview.cr.endHeaderRefresh()
            })
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delayTimer.delegate = self
    
        switch mode {
        case .normal:
            NotificationCenter.default.addObserver(self, selector: #selector(handleSwitchToChat), name: Notifications.StartConversation, object: nil)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationCenter.default.addObserver(self, selector: #selector(handleFetchData), name: Notifications.RefreshChat, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notifications.RefreshChat, object: nil)
    }
    
    deinit {
        switch mode {
        case .normal:
            NotificationCenter.default.removeObserver(self, name: Notifications.StartConversation, object: nil)
        default:
            break
        }
    }
    
    @objc func handleSwitchToChat(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let user = userInfo["user"] as? ListUser, user.identifier != userManager.user?.identifier {
            let schedule = userInfo["schedule"] as? Schedule
            let message = userInfo["message"] as? String
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.goToChat(talkingTo: user, schedule: schedule, message: message)
            })
        } else if let userId = userInfo["userId"] as? Int {
            FullScreenSpinner().show()
            
            api.getUser(userId: userId) { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let res):
                    self?.goToChat(talkingTo: res.toSimpleUser(), schedule: nil, message: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChat" {
            let vc = segue.destination as! ChatViewController
            vc.talkingTo = selectedUser
            vc.schedule = selectedSchedule
            vc.intialMessage = initialMessage
            vc.delegate = self
        } else if segue.identifier == "goToArchive" {
            let vc = segue.destination as! ChatConversationsViewController
            vc.mode = .archive
        }
    }
    
    @objc private func handleFetchData() {
        fetchData()
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        switch mode {
        case .normal:
            conversations == nil ? FullScreenSpinner().show() : nil
            userManager.fetchConversations { conversations, error in
                FullScreenSpinner().hide()
                
                if let error = error {
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                    complete?(false)
                } else if let conversations = conversations {
                    self.conversations = conversations
                    self.shouldSearch(text: self.searchBar.text ?? "")
                    complete?(true)
                } else {
                    complete?(false)
                }
            }
        default:
            break
        }
    }

    private func goToChat(talkingTo: ListUser, schedule: Schedule?, message: String?) {
        selectedUser = talkingTo
        selectedSchedule = schedule
        initialMessage = message
        performSegue(withIdentifier: "showChat", sender: self)
    }
}

extension ChatConversationsViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let searchText: String = text.trim()
        
        if searchText.count < 3 {
            displaying = conversations ?? []
        } else {
            displaying = (conversations ?? []).filter({ each in
                let nameFound = each.user.fullName.contains(string: searchText, caseInsensitive: true)
                let messageFound = each.chatMessage.userMessage.contains(string: searchText, caseInsensitive: true)
                
                return nameFound || messageFound
            })
        }
    }
}

extension ChatConversationsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delayTimer.textDidGetEntered(text: searchText)
    }
}

extension ChatConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displaying.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListCell", for: indexPath) as? MessageListCell else {
            return MessageListCell()
        }
        
        cell.config(data: displaying[indexPath.row])
        cell.backgroundColor = indexPath.row % 2 == 0 ? themeManager.themeData!.whiteBackground.hexColor : themeManager.themeData!.defaultBackground.hexColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let talkingTo = displaying[indexPath.row].user
        goToChat(talkingTo: talkingTo, schedule: nil, message: nil)
    }
}

extension ChatConversationsViewController: ChatViewControllerDelegate {
    func requestRefreshConversations() {
        fetchData()
    }
}
