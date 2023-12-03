//
//  CallingViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-24.
//

import UIKit

class CallingViewController: BaseViewController {
    var callingUser: ListUser!
    var schedule: Schedule!
    var channelName: String!
    var token: String!

    private enum MeetingState {
        case ongoing
        case almostOver
        case ended
    }
    
    private let manager = AgoraManager.shared
    
    @IBOutlet weak var leftContainer: UIView!
    @IBOutlet weak var rightContainer: UIView!
    
    @IBOutlet weak var badConnectionContainer: UIView!
    @IBOutlet weak var connectionProblemLabel: UILabel!
    
    @IBOutlet weak var leftAvatar: UIImageView!
    @IBOutlet weak var leftName: UILabel!
    @IBOutlet weak var leftJob: UILabel!
    @IBOutlet weak var leftMute: UIImageView!
    
    @IBOutlet weak var rightAvatar: UIImageView!
    @IBOutlet weak var rightName: UILabel!
    @IBOutlet weak var rightJob: UILabel!
    @IBOutlet weak var rightMute: UIImageView!
    
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeWarningContainer: UIView!
    @IBOutlet weak var timeWarningLabel: UILabel!
    
    @IBOutlet weak var muteImage: UIImageView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var speakerButton: UIButton!
    
    private var meetingState: MeetingState = .ongoing {
        didSet {
            switch meetingState {
            case .ongoing:
                timeWarningContainer.isHidden = true
            case .almostOver:
                timeWarningContainer.isHidden = false
                timeWarningLabel.text = "You have 5 minutes left in this booking."
            case .ended:
                timeWarningContainer.isHidden = false
                timeWarningLabel.text = "Meeting ended."
            }
        }
    }
    
    private var refreshTimer: Timer?
    
    static func create(callingUser: ListUser, schedule: Schedule, channelName: String, token: String) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Calling", viewControllerId: "CallingViewController") as! CallingViewController
        vc.callingUser = callingUser
        vc.schedule = schedule
        vc.channelName = channelName
        vc.token = token
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    override func setup() {
        super.setup()
        
        callButton.roundCorners()
        navigationController?.navigationBar.isHidden = true
        leftMute.isHidden = true
        
        rightMute.isHidden = true
        rightAvatar.isHidden = true
        rightName.isHidden = true
        rightJob.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.theme == .light ? themeManager.themeData!.indigo.hexColor : themeManager.themeData!.defaultBackground.hexColor
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        manager.fullScreenCallViewOpened = true
        startObserveAgoraManager()
        refreshView()
        UIApplication.shared.isIdleTimerDisabled = true
        if meetingState != .ended {
            refreshTimer = Timer.scheduledTimer(timeInterval: 5,
                                                target: self,
                                                selector: #selector(timerFunction),
                                                userInfo: nil,
                                                repeats: true)
            refreshTimer?.fire()
        }
        
        if !manager.inInACall {
            dismiss(animated: true, completion: nil)
        }
        userManager.inCallScreen = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        manager.fullScreenCallViewOpened = false
        stopObserveAgoraManager()
        UIApplication.shared.isIdleTimerDisabled = false
        refreshTimer?.invalidate()
        refreshTimer = nil
        userManager.inCallScreen = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        muteButton.roundCorners(style: .completely)
        speakerButton.roundCorners(style: .completely)
    }
    
    @objc func timerFunction() {
        if Date() >= schedule.endTime {
            meetingState = .ended
        } else if Date() > schedule.endTime.getPastOrFutureDate(minute: -5) {
            meetingState = .almostOver
        } else {
            meetingState = .ongoing
        }
    }
    
    @IBAction func mutePress(_ sender: Any) {
        if manager.myMicState == MicStates.speaking.rawValue {
            manager.mutedMic()
        } else {
            manager.unmutedMic()
        }
    }
    
    @IBAction func speakerPress(_ sender: Any) {
        switch SpeakerStates(rawValue: AgoraManager.shared.speakerState) {
        case .muted:
            manager.useEar()
        case .ear:
            manager.useSpeaker()
        case .speaker:
            manager.mutedSpeaker()
        default:
            break
        }
    }
    
    @IBAction func hangUpPress(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "End the call?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Be right back", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.manager.leaveChannel()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Terminate call", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.manager.handleTerminateCall()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func refreshView() {
        guard let myself = userManager.user else { return }
        
        if let urlString = callingUser.avatar?.smallUrl, let url = URL(string: urlString) {
            rightAvatar.kf.setImage(with: url)
        } else {
            rightAvatar.image = callingUser.defaultAvatar
        }
        
        rightName.text = callingUser.fullName
        rightJob.text = callingUser.jobDescription
        
        if let myAvatarURL = myself.avatarURL, let url = URL(string: myAvatarURL) {
            leftAvatar.kf.setImage(with: url)
        } else {
            leftAvatar.image = myself.defaultAvatar
        }
        
        leftName.text = myself.fullName
        leftJob.text = myself.jobDescription
        
        topicLabel.text = schedule.title
        timeLabel.text = "Meeting ends at \(DateUtil.convert(input: schedule.endTime, outputFormat: .format8) ?? "")"
    }
    
    func startObserveAgoraManager() {
        manager.addObserver(self, forKeyPath: "inInACall", options: [.initial, .new], context: nil)
        manager.addObserver(self, forKeyPath: "connectionState", options: [.initial, .new], context: nil)
        manager.addObserver(self, forKeyPath: "speakerState", options: [.initial, .new], context: nil)
        manager.addObserver(self, forKeyPath: "myMicState", options: [.initial, .new], context: nil)
        manager.addObserver(self, forKeyPath: "remoteMicState", options: [.initial, .new], context: nil)
    }
    
    func stopObserveAgoraManager() {
        if manager.observationInfo != nil {
            manager.removeObserver(self, forKeyPath: "inInACall", context: nil)
            manager.removeObserver(self, forKeyPath: "connectionState", context: nil)
            manager.removeObserver(self, forKeyPath: "speakerState", context: nil)
            manager.removeObserver(self, forKeyPath: "myMicState", context: nil)
            manager.removeObserver(self, forKeyPath: "remoteMicState", context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "inInACall" {
            let inInACall = change?[.newKey] as? Bool ?? false
            if !inInACall {
                self.dismiss(animated: true, completion: nil)
            }
        } else if keyPath == "connectionState", let connectionState = change?[.newKey] as? Int {
            switch ConnectionStates(rawValue: connectionState) {
            case .waiting:
                badConnectionContainer.isHidden = false
                connectionProblemLabel.text = "Waiting"
                rightAvatar.isHidden = true
                rightName.isHidden = true
                rightJob.isHidden = true
            case .ready:
                badConnectionContainer.isHidden = true
                connectionProblemLabel.text = ""
                rightAvatar.isHidden = false
                rightName.isHidden = false
                rightJob.isHidden = false
            case .disconnected:
                badConnectionContainer.isHidden = false
                connectionProblemLabel.text = "Disconnected"
                rightAvatar.isHidden = true
                rightName.isHidden = true
                rightJob.isHidden = true
            default:
                badConnectionContainer.isHidden = false
                connectionProblemLabel.text = "Not in a session"
                rightAvatar.isHidden = true
                rightName.isHidden = true
                rightJob.isHidden = true
            }
        } else if keyPath == "speakerState", let speakerState = change?[.newKey] as? Int {
            switch SpeakerStates(rawValue: speakerState) {
            case .muted:
                speakerImage.image = UIImage(systemName: "speaker.slash.fill")!
            case .ear:
                speakerImage.image = UIImage(systemName: "ear")!
            case .speaker:
                speakerImage.image = UIImage(systemName: "speaker.wave.3.fill")!
            default:
                speakerImage.image = nil
            }
        } else if keyPath == "myMicState", let myMicState = change?[.newKey] as? Int {
            switch MicStates(rawValue: myMicState) {
            case .muted:
                muteImage.isHidden = false
                muteImage.image = UIImage(systemName: "mic.slash.fill")!
                leftMute.isHidden = false
            case .speaking:
                muteImage.isHidden = false
                muteImage.image = UIImage(systemName: "mic.fill")!
                leftMute.isHidden = true
            default:
                muteImage.isHidden = true
                leftMute.isHidden = true
            }
        } else if keyPath == "remoteMicState", let remoteMicState = change?[.newKey] as? Int {
            switch MicStates(rawValue: remoteMicState) {
            case .muted:
                rightMute.isHidden = false
            case .speaking:
                rightMute.isHidden = true
            default:
                rightMute.isHidden = true
            }
        }
    }
}
