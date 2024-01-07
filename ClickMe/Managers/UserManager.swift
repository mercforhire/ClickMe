//
//  UserManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-27.
//

import Foundation
import Valet
import Alamofire

struct LoginInfo: Codable {
    var email: String?
    var token: String?
    var refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case token
        case refreshToken
    }
    
    func encodeToData() -> Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        }
        
        return nil
    }
    
    static func decodeFromData(data: Data) -> LoginInfo? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(LoginInfo.self, from: data) {
            return decoded
        }
        
        return nil
    }
}

class UserManager {
    var loginInfo: LoginInfo
    var user: CompleteUser?
    lazy var setupManager = SetupProfileManager(userManager: self)
    var talkingWith: ListUser?
    var inCallScreen: Bool = false
    
    static let shared = UserManager()
    
    private var api: ClickAPI {
        return ClickAPI.shared
    }
    private let myValet = Valet.valet(with: Identifier(nonEmpty: "ClickMe")!, accessibility: .whenUnlocked)
    private var conversations: [Message]?
    
    init() {
        if let data = try? myValet.object(forKey: "loginInfo") {
            loginInfo = LoginInfo.decodeFromData(data: data) ?? LoginInfo()
        } else {
            loginInfo = LoginInfo()
        }
        api.service.accessToken = loginInfo.token
    }
    
    func isLoggedIn() -> Bool {
        return !(loginInfo.token?.isEmpty ?? true)
    }
    
    func sendEmailCode(sender: UIButton? = nil, email: String, checkForEmailExistence: Bool) {
        let originalTitle = sender?.titleLabel?.text
        sender?.isEnabled = false
        sender?.setTitle("Sending", for: .normal)
        
        FullScreenSpinner().show()
        api.getEmailCode(email: email, checkForEmailExistence: checkForEmailExistence) { result in
            
            sender?.isEnabled = true
            FullScreenSpinner().hide()
            
            switch result {
            case .success:
                sender?.setTitle("Sent", for: .normal)
            case .failure(let error):
                sender?.setTitle(originalTitle, for: .normal)
                guard let errorCode = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                if errorCode == 409 {
                    showErrorDialog(error: "Wait 10 seconds before sending another code.")
                } else if errorCode == 416 {
                    showErrorDialog(error: "Another user with this email address does not exist.")
                } else {
                    showErrorDialog(error: error.errorDescription ?? "")
                }
            }
        }
    }
    
    func login(email: String, code: String, completion: @escaping (Bool) -> Void) {
        api.login(email: email, code: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.loginInfo.email = email
                self.loginInfo.token = response.token
                self.loginInfo.refreshToken = response.refreshToken
                self.api.service.accessToken = response.token
                self.saveLoginInfo()
                completion(true)
            case .failure(let error):
                guard let errorCode = error.responseCode else {
                    showNetworkErrorDialog()
                    completion(false)
                    return
                }
                
                if errorCode == 433 {
                    showErrorDialog(error: "Account with the email address is not found")
                } else if errorCode == 434 {
                    showErrorDialog(error: "Verification is incorrect")
                } else {
                    error.showErrorDialog()
                }
                
                completion(false)
            }
        }
    }
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        api.getDetailUser { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.user = user
                completion(true)
            case .failure(let error):
                error.showErrorDialog()
                completion(false)
            }
        }
    }
    
    func updateUser(params: UpdateUserParams, completion: @escaping (Bool) -> Void) {
        FullScreenSpinner().show()
        api.updateProfile(updateForm: params) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            switch result {
            case .success:
                self.user?.updateUser(params: params)
                completion(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                
                completion(false)
            }
        }
    }
    
    func blockUser(userId: Int, completion: @escaping (Bool) -> Void) {
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.blockUser(otherUserId: userId) { result in
                switch result {
                case .success:
                    isSuccess = true
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                completion(isSuccess)
            }
        }
    }
    
    func unblockUser(userId: Int, completion: @escaping (Bool) -> Void) {
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.unblockUser(otherUserId: userId) { result in
                switch result {
                case .success:
                    isSuccess = true
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                completion(isSuccess)
            }
        }
    }
    
    func followUser(userId: Int, completion: @escaping (Bool) -> Void) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        FullScreenSpinner().show()
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.followUser(otherUserId: userId) { result in
                switch result {
                case .success:
                    isSuccess = true
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                completion(isSuccess)
            }
        }
    }
    
    func unfollowUser(userId: Int, completion: @escaping (Bool) -> Void) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        FullScreenSpinner().show()
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.unfollowUser(otherUserId: userId) { result in
                switch result {
                case .success:
                    isSuccess = true
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                completion(isSuccess)
            }
        }
    }
    
    func saveSchedule(scheduleId: Int, completion: @escaping (Bool) -> Void) {
        FullScreenSpinner().show()
        api.followSchedule(scheduleId: scheduleId) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            switch result {
            case .success:
                if self.user?.favoriteSchedules == nil {
                    self.user?.favoriteSchedules = []
                }
                self.user?.favoriteSchedules?.append(scheduleId)
                completion(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                completion(false)
            }
        }
    }
    
    func unSaveSchedule(scheduleId: Int, completion: @escaping (Bool) -> Void) {
        FullScreenSpinner().show()
        api.unfollowSchedule(scheduleId: scheduleId) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            switch result {
            case .success:
                if let idx = self.user?.favoriteSchedules?.firstIndex(where: { $0 == scheduleId }) {
                    self.user?.favoriteSchedules?.remove(at: idx)
                }
                completion(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                completion(false)
            }
        }
    }
    
    func uploadProfilePhoto(data: Data, completion: @escaping (Bool) -> Void) {
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        var uploadResponse: UploadPhotoResponse?
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            self.api.uploadPhoto(data: data) { result in
                switch result {
                case .success(let response):
                    uploadResponse = response
                    isSuccess = true
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
            
            guard isSuccess, let avatar = uploadResponse else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                    completion(false)
                }
                return
            }
            
            var updateUser = UpdateUserParams()
            updateUser.userPhotos = self.user?.getUploadPhotoResponseArray() ?? []
            updateUser.userPhotos?.append(avatar)
            self.api.updateProfile(updateForm: updateUser) { result in
                switch result {
                case .success:
                    isSuccess = true
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                completion(isSuccess)
            }
        }
    }
    
    func swapProfilePhotos(source: Int, destination: Int, completion: @escaping (Bool) -> Void) {
        guard let user = user,
              source < user.photos?.count ?? 0,
              destination < user.photos?.count ?? 0 else { return }
        
        var isSuccess: Bool = true
        
        FullScreenSpinner().show()
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            var updateUser = UpdateUserParams()
            updateUser.userPhotos = user.getUploadPhotoResponseArray()
            updateUser.userPhotos?.swapAt(source, destination)
            self.api.updateProfile(updateForm: updateUser) { result in
                switch result {
                case .success:
                    isSuccess = true
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
                }
                return
            }
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
            }
        }
    }
    
    func deleteProfilePhoto(index: Int, deleteThis: Photo, completion: @escaping (Bool) -> Void) {
        guard let user = user, index < user.photos?.count ?? 0 else { return }
        
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        
        var resultPhotos: [UploadPhotoResponse] = user.getUploadPhotoResponseArray()
        resultPhotos.remove(at: index)
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            var updateUser = UpdateUserParams()
            updateUser.userPhotos = resultPhotos
            self.api.updateProfile(updateForm: updateUser) { result in
                switch result {
                case .success:
                    isSuccess = true
                    self.user?.photos?.remove(at: index)
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
                }
                return
            }
            
            self.api.deletePhoto(photoId: deleteThis.identifier) { result in
                switch result {
                case .success:
                    isSuccess = true
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
            
            DispatchQueue.main.async {
                FullScreenSpinner().hide()
                
                completion(isSuccess)
            }
        }
    }
    
    func uploadProfileVideo(fileURL: URL, thumbnailImage: UIImage, progressUpdate: @escaping (Double) -> Void,  completion: @escaping (Bool) -> Void) {
        var uploadResponse: UploadVideoResponse?
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.uploadVideo(videoPath: fileURL, thumbnailImage: thumbnailImage, progressUpdate: progressUpdate) { result in
                switch result {
                case .success(let response):
                    uploadResponse = response
                    isSuccess = true
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
            
            guard isSuccess, let uploadResponse = uploadResponse else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            var updateUser = UpdateUserParams()
            updateUser.videoURL = uploadResponse.videoUrl
            self.api.updateProfile(updateForm: updateUser) { result in
                switch result {
                case .success:
                    isSuccess = true
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                completion(isSuccess)
            }
        }
    }
    
    func deleteProfileVideo(completion: @escaping (Bool) -> Void) {
        guard let _ = user?.videoURL else { return }
        
        FullScreenSpinner().show()
        api.deleteVideo { result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success:
                self.user?.videoURL = nil
                completion(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                
                completion(false)
            }
        }
    }
    
    func changeEmail(newEmail: String, emailCode: String, completion: @escaping (Bool) -> Void) {
        FullScreenSpinner().show()
        api.changeEmail(newEmail: newEmail, emailCode: emailCode) { result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success:
                self.fetchUser { success in
                    completion(success)
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else if error.responseCode == 401 {
                    showErrorDialog(error: "New email already taken by someone else.")
                } else if error.responseCode == 413 {
                    showErrorDialog(error: "Email code is wrong")
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                
                completion(false)
            }
        }
    }
    
    func fetchConversations(complete: (([Message]?, AFError?) -> Void)? = nil) {
        api.getLatestMessage { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let res):
                self.conversations = res
                let badgeCount = res.filter({ subject in
                    return !subject.isFromMyself && subject.chatMessage.read == false
                }).count
                NotificationCenter.default.post(name: Notifications.UpdateChatBadge, object: nil, userInfo: ["badgeCount": badgeCount])
                complete?(res, nil)
            case .failure(let error):
                complete?(nil, error)
            }
        }
    }
    
    func fetchHostSchedule(complete: (([Schedule]?, AFError?) -> Void)? = nil) {
        api.getUserSchedules() { result in
            switch result {
            case .success(let response):
                let pending = response.filter { subject in
                    return subject.status == .pending
                }.count
                
                let upcomingTotal = response.filter { subject in
                    return subject.startTime.isInToday() && subject.status == .upcoming
                }.count
                
                NotificationCenter.default.post(name: Notifications.UpdateHostCalenderBadge, object: nil, userInfo: ["badgeCount": pending + upcomingTotal])
                complete?(response, nil)
            case .failure(let error):
                complete?(nil, error)
            }
        }
    }
    
    func logOut() {
        AppSettingsManager.shared.resetSettings()
        user = nil
        loginInfo.token = nil
        conversations = nil
        try? myValet.removeAllObjects()
        saveLoginInfo()
        setupManager.reset()
        AgoraManager.shared.resetValues()
        inCallScreen = false
    }
    
    private func saveLoginInfo() {
        if let data = loginInfo.encodeToData() {
            try? myValet.setObject(data, forKey: "loginInfo")
        }
    }
}
