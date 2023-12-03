//
//  BookCallViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-13.
//

import UIKit
import AgoraRtcKit

class BookCallViewController: BaseViewController {
    var schedule: Schedule!
    
    private enum Mode {
        case waiting
        case ready
        case expired
        
        func message() -> String {
            switch self {
            case .waiting:
                return "You can call 5 mins before the booking"
            case .ready:
                return "You can now start the call"
            case .expired:
                return "It's past the session's end time"
            }
            
        }
    }
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    private var refreshTimer: Timer?
    
    private var mode: Mode = .waiting {
        didSet {
            statusLabel.text = mode.message()
            switch mode {
            case .waiting:
                joinButton.isEnabled = false
                joinButton.backgroundColor = .lightGray
            case .ready:
                joinButton.isEnabled = true
                joinButton.backgroundColor = .systemIndigo
            case .expired:
                joinButton.isEnabled = false
                joinButton.backgroundColor = .lightGray
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        avatar.roundCorners()
        statusLabel.text = mode.message()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTimer = Timer.scheduledTimer(timeInterval: 10,
                                            target: self,
                                            selector: #selector(timerFunction),
                                            userInfo: nil,
                                            repeats: true)
        refreshTimer?.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @objc func timerFunction() {
        guard mode != .ready else {
            refreshTimer?.invalidate()
            refreshTimer = nil
            return
        }
        
        if Date() < schedule.startTime.getPastOrFutureDate(minute: -5) {
            mode = .waiting
        } else if Date() >= schedule.endTime {
            mode = .expired
        } else {
            mode = .ready
            AgoraManager.shared.initializeAgora()
        }
    }
    
    @IBAction func callPressed(_ sender: Any) {
        FullScreenSpinner().show()
        
        var token: String?
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.updateStatus(scheduleId: self.schedule.identifier, status: .started) { result in
                switch result {
                case .success:
                    isSuccess = true
                case .failure(let error):
                    // 498 SCHEDULE_OVERRED: Schedule overred
                    // 499 NOT_START_YET: Schedule not start yet
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else if error.responseCode == 499 {
                        showErrorDialog(error: "UpdateStatus: Please wait until 5 minutes before the scheduled start time.")
                    } else {
                        error.showErrorDialog()
                        print("UpdateStatus: Error occured \(error)")
                    }
                    isSuccess = false
                }
                
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.api.getRtcToken(scheduleId: self.schedule.identifier) { result in
                switch result {
                case .success(let res):
                    isSuccess = true
                    token = res.RTCToken
                case .failure(let error):
                    // 498 SCHEDULE_OVERRED: Schedule overred
                    // 499 NOT_START_YET: Schedule not start yet
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else if error.responseCode == 498 {
                        showErrorDialog(error: "GetRtcToken: Booked session is already over.")
                    } else if error.responseCode == 499 {
                        showErrorDialog(error: "GetRtcToken: Please wait until 5 minutes before the scheduled start time.")
                    } else {
                        error.showErrorDialog()
                        print("GetRtcToken: Error occured \(error)")
                    }
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                guard let token = token, let roomId = self.schedule.roomId, let booker = self.schedule.booker else { return }
                
                let callingUser: ListUser = booker.isMyself ? self.schedule.host : booker
                AgoraManager.shared.joinChannel(presentCallView: true,
                                                callingUser: callingUser,
                                                schedule: self.schedule,
                                                token: token,
                                                channelId: roomId) { [weak self] in
                    self?.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
    
    private func refreshView() {
        var callingUser: ListUser?
        
        if schedule.host.identifier == self.userManager.user?.identifier, schedule.booker != nil {
            callingUser = schedule.booker
        } else if schedule.booker?.identifier == self.userManager.user?.identifier {
            callingUser = schedule.host
        }
        
        guard let callingUser = callingUser else { return }
        
        if let urlString = callingUser.avatar?.smallUrl, let url = URL(string: urlString) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = callingUser.defaultAvatar
        }
        nameLabel.text = callingUser.fullName
        jobLabel.text = callingUser.jobDescription
        mode = .waiting
    }
}
