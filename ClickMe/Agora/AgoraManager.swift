//
//  AgoraManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-09-14.
//

import Foundation
import AgoraRtcKit

enum ConnectionStates: Int {
    case waiting
    case ready
    case disconnected
}

enum SpeakerStates: Int {
    case muted
    case ear
    case speaker
}

enum MicStates: Int {
    case muted
    case speaking
}

class AgoraManager: NSObject {

    static let shared = AgoraManager()
    
    var showErrors: Bool = false
    
    private(set) var callingUser: ListUser?
    private(set) var schedule: Schedule?
    private(set) var token: String?
    private(set) var channelId: String?
    
    @objc dynamic private(set) var inInACall: Bool = false
    @objc dynamic var fullScreenCallViewOpened: Bool = false
    @objc dynamic private(set) var connectionState: Int = -1
    @objc dynamic private(set) var speakerState: Int = -1
    @objc dynamic private(set) var myMicState: Int = -1
    @objc dynamic private(set) var remoteMicState: Int = -1
    
    private var agoraKit: AgoraRtcEngineKit!
    private var audioProfile: AgoraAudioProfile = .default
    private var audioScenario: AgoraAudioScenario = .default
    private var callButton: CallButton!
    
    func initializeAgora() {
        guard agoraKit == nil else { return }
        
        // set up agora instance when view loaded
        let config = AgoraRtcEngineConfig()
        config.areaCode = AgoraAreaCode.GLOB.rawValue
        config.appId = AgoraKeyCenter.AppId
        
        // setup log file path
        let logConfig = AgoraLogConfig()
        logConfig.level = .info
        config.logConfig = logConfig
        
        // initialize Agora Engine
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
            
        agoraKit.setChannelProfile(.communication)
        agoraKit.setClientRole(.broadcaster)
        
        // disable video module
        agoraKit.disableVideo()
        
        // set audio profile/audio scenario
        agoraKit.setAudioProfile(audioProfile, scenario: audioScenario)
        
        // Set audio route to speaker
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        // enable volume indicator
        agoraKit.enableAudioVolumeIndication(200, smooth: 3, report_vad: false)
        
        agoraKit.setEnableSpeakerphone(true)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEndedCall), name: Notifications.EndedCall, object: nil)
        
        callButton = CallButton()
    }
    
    func joinChannel(presentCallView: Bool,
                     callingUser: ListUser,
                     schedule: Schedule,
                     token: String,
                     channelId: String,
                     completion: (() -> Void)? = nil ) {
        self.callingUser = callingUser
        self.schedule = schedule
        self.token = token
        self.channelId = channelId
        
        if inInACall {
            print("AgoraManager: can't join channel, already in a call.")
            openCallScreen()
            return
        }
        
        // start joining channel
        // 1. Users can only see each other after they join the
        // same channel successfully using the same app id.
        // 2. If app certificate is turned on at dashboard, token is needed
        // when joining channel. The channel name and uid used to calculate
        // the token has to match the ones used for channel join
        agoraKit.joinChannel(byToken: token, channelId: channelId, info: nil, uid: 0) { (sid, uid, elapsed) -> Void in
            print("AgoraManager: joinChannel: \(sid), \(uid), \(elapsed)")
            self.connectionState = ConnectionStates.waiting.rawValue
            self.inInACall = true
            self.speakerState = SpeakerStates.speaker.rawValue
            self.myMicState = MicStates.speaking.rawValue
            self.remoteMicState = MicStates.speaking.rawValue
            if presentCallView {
                self.openCallScreen()
            }
            self.callButton.startObserveAgoraManager()
            completion?()
        }
    }
    
    @objc func handleEndedCall() {
        guard inInACall,
              connectionState == ConnectionStates.disconnected.rawValue,
              let topVC = UIViewController.topViewController,
              let callingUser = callingUser else { return }
        
        let alert = UIAlertController(title: nil, message: "\(callingUser.firstName) has terminated call", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            self?.handleTerminateCall()
        }))
        topVC.present(alert, animated: true, completion: nil)
    }
    
    func mutedMic() {
        guard inInACall else { return }
        
        agoraKit.muteLocalAudioStream(true)
        myMicState = MicStates.muted.rawValue
    }
    
    func unmutedMic() {
        guard inInACall else { return }
        
        agoraKit.muteLocalAudioStream(false)
        myMicState = MicStates.speaking.rawValue
    }
    
    func mutedSpeaker() {
        guard inInACall else { return }
        
        agoraKit.adjustPlaybackSignalVolume(0)
        speakerState = SpeakerStates.muted.rawValue
    }
    
    func useEar() {
        guard inInACall else { return }
        
        agoraKit.setEnableSpeakerphone(false)
        agoraKit.adjustPlaybackSignalVolume(100)
        speakerState = SpeakerStates.ear.rawValue
    }
    
    func useSpeaker() {
        guard inInACall else { return }
        
        agoraKit.setEnableSpeakerphone(true)
        agoraKit.adjustPlaybackSignalVolume(100)
        speakerState = SpeakerStates.speaker.rawValue
    }
    
    func leaveChannel(completion: (() -> Void)? = nil) {
        guard inInACall else { return }
        
        agoraKit.leaveChannel { stats in
            print("AgoraManager leaveChannel:\(stats)")
            self.inInACall = false
            self.callButton.stopObserveAgoraManager()
            completion?()
        }
    }
    
    func resetValues() {
        inInACall = false
        callingUser = nil
        schedule = nil
        token = nil
        channelId = nil
        connectionState = -1
        speakerState = -1
        myMicState = -1
        remoteMicState = -1
        callingUser = nil
        schedule = nil
    }
    
    func handleTerminateCall() {
        leaveChannel {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
                self?.updateScheduleToFinish()
            })
        }
    }
    
    private func updateScheduleToFinish() {
        guard let schedule = schedule else { return }
        
        ClickAPI.shared.updateStatus(scheduleId: schedule.identifier, status: .finished) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.goToReview()
            case .failure(let error):
                // 494 ROOM_UPDATE_FAILED: Room status update failed
                // 499 NOT_START_YET: Schedule not start yet
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    showErrorDialog(error: "Terminate call failed, error code:\(error.responseCode ?? 0)")
                }
            }
        }
    }
    
    func openCallScreen() {
        guard let topVC = UIViewController.topViewController,
              let callingUser = callingUser,
              let schedule = schedule,
              let channelName = channelId,
              let token = token
            else { return }
        
        let vc = CallingViewController.create(callingUser: callingUser, schedule: schedule, channelName: channelName, token: token)
        topVC.present(vc, animated: true, completion: nil)
    }
    
    private func goToReview() {
        guard let topVC = UIViewController.topViewController,
              let callingUser = callingUser,
              let schedule = schedule else { return }
        
        let vc = RateCallViewController.createFullScreenVC(callingUser: callingUser, schedule: schedule)
        topVC.present(vc, animated: true) {
            self.resetValues()
        }
    }
}

extension AgoraManager: AgoraRtcEngineDelegate {
    /// callback when warning occured for agora sdk, warning can usually be ignored, still it's nice to check out
    /// what is happening
    /// Warning code description can be found at:
    /// en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraWarningCode.html
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraWarningCode.html
    /// @param warningCode warning code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("AgoraManager warning: \(warningCode.description)")
    }
    
    /// callback when error occured for agora sdk, you are recommended to display the error descriptions on demand
    /// to let user know something wrong is happening
    /// Error code description can be found at:
    /// en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
    /// @param errorCode error code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        if errorCode == .tokenExpired {
            handleTerminateCall()
        } else {
            print("AgoraManager rtcEngine error: \(errorCode.description)")
            if showErrors {
                showErrorDialog(error: "AgoraManager rtcEngine error: \(errorCode.description)")
            }
        }
    }
    
    /// callback when the local user joins a specified channel.
    /// @param channel
    /// @param uid uid of local user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("AgoraManager join \(channel) with uid \(uid) elapsed \(elapsed)ms")
        
    }
    
    /// callback when a remote user is joinning the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("AgoraManager remote user join: \(uid) \(elapsed)ms")
        connectionState = ConnectionStates.ready.rawValue
    }
    
    /// callback when a remote user is leaving the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param reason reason why this user left, note this event may be triggered when the remote user
    /// become an audience in live broadcasting profile
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("AgoraManager remote user left: \(uid) reason \(reason)")
        connectionState = ConnectionStates.disconnected.rawValue
    }
    
    /// Reports which users are speaking, the speakers' volumes, and whether the local user is speaking.
    /// @params speakers volume info for all speakers
    /// @params totalVolume Total volume after audio mixing. The value range is [0,255].
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeIndicationOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
        
    }
    
    /// Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        
    }
    
    /// Reports the statistics of the uploading local audio streams once every two seconds.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStats stats: AgoraRtcLocalAudioStats) {
        
    }
    
    /// Reports the statistics of the audio stream from each remote user/host.
    /// @param stats stats struct for current call statistics
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioMuted muted: Bool, byUid uid: UInt) {
        if uid != 0 {
            remoteMicState = muted ? MicStates.muted.rawValue : MicStates.speaking.rawValue
        }
        print("AgoraManager uid\(uid) muted \(muted ? "muted" : "unmuted")")
    }
}
