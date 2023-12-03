//
//  AuthenticationService.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation
import Alamofire

class ClickAPI {
    static let shared = ClickAPI()
    
    var baseURL = "http://15.222.166.60"
    let service: NetworkService
    
    init() {
        self.service = NetworkService()
    }
    
    func getEmailCode(email: String, checkForEmailExistence: Bool, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let params: [String : Any] = ["email": email, "checkEmail": checkForEmailExistence]
        let url = baseURL + APIRequestURLs.getEmailCode.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getEmailCode.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getSMSCode(areaCode: String, phone: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let params = ["areaCode": areaCode, "phone": phone]
        let url = baseURL + APIRequestURLs.getSMSCode.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getSMSCode.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func login(email: String, password: String, callBack: @escaping(Result<TokenResponse, AFError>) -> Void) {
        let params = ["email": email, "password": password]
        let url = baseURL + APIRequestURLs.signInWithEmail.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.signInWithEmail.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<TokenResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func login(areaCode: String, phone: String, smsCode: String, callBack: @escaping(Result<TokenResponse, AFError>) -> Void) {
        let params = ["areaCode": areaCode,
                      "phone": phone,
                      "smscode": smsCode]
        let url = baseURL + APIRequestURLs.signInWithPhone.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.signInWithPhone.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<TokenResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func signUpWithEmail(email: String, emailCode: String, password: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let params = ["email": email,
                      "emailCode": emailCode,
                      "password": password]
        let url = baseURL + APIRequestURLs.signUpWithEmail.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.signUpWithEmail.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func signUpWithPhone(areaCode: String, phone: String, smsCode: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let params = ["areaCode": areaCode,
                      "phone": phone,
                      "smscode": smsCode]
        let url = baseURL + APIRequestURLs.signUpWithPhone.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.signUpWithPhone.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getUser(userId: Int, callBack: @escaping(Result<PublicUser, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getUser.rawValue
        let params = ["user_id": userId]
        
        service.httpRequest(url: url, method: APIRequestURLs.getUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<PublicUser>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getDetailUser(callBack: @escaping(Result<CompleteUser, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getCompleteUser.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.getCompleteUser.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<CompleteUser>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func updateProfile(updateForm: UpdateUserParams, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.updateProfile.rawValue

        service.httpRequestSimple(url: url, method: APIRequestURLs.updateProfile.getHTTPMethod(), parameters: updateForm.params(), headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func forgetPassword(email: String, emailCode: String, newPassword: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let params = ["email": email,
                      "emailCode": emailCode,
                      "newPassword": newPassword]
        
        let url = baseURL + APIRequestURLs.forgetPassword.rawValue
        service.httpRequestSimple(url: url, method: APIRequestURLs.forgetPassword.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func uploadPhoto(data: Data, callBack: @escaping(Result<UploadPhotoResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.uploadPhotos.rawValue
        
        service.uploadData(url: url, method: APIRequestURLs.uploadPhotos.getHTTPMethod(), headers: Headers.defaultHeader(), data: data) { (result: AFResult<UploadPhotoResponse>) in
            switch result {
            case .success(let photo):
                callBack(.success(photo))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func deletePhoto(photoId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.deletePhotos.rawValue
        let params = ["deletePhotos": [photoId]]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.deletePhotos.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func uploadVideo(videoPath: URL, thumbnailImage: UIImage, progressUpdate: @escaping (Double) -> Void, callBack: @escaping(Result<UploadVideoResponse, AFError>) -> Void) {
        guard let thumbnailData = thumbnailImage.jpeg else { return }
        
        let url = baseURL + APIRequestURLs.uploadVideo.rawValue
        service.uploadVideo(url: url, method: APIRequestURLs.uploadVideo.getHTTPMethod(), headers: Headers.defaultHeader(), thumbnailData: thumbnailData, fileURL: videoPath, progressUpdate: progressUpdate) { (result: AFResult<UploadVideoResponse>) in
            switch result {
            case .success(let photo):
                callBack(.success(photo))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func deleteVideo(callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.deleteVideo.rawValue
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.deleteVideo.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func exploreUsers(params: ExploreUserParams, callBack: @escaping(Result<ExploreUsersResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.exploreUsers.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.exploreUsers.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<ExploreUsersResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getFollowedUsers(userId: Int, callBack: @escaping(Result<[ListUser], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getFollowees.rawValue
        let params = ["userId": userId]
        
        service.httpRequest(url: url, method: APIRequestURLs.getFollowees.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[ListUser]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getFollowers(userId: Int, callBack: @escaping(Result<[ListUser], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getFollowers.rawValue
        let params = ["userId": userId]

        service.httpRequest(url: url, method: APIRequestURLs.getFollowers.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[ListUser]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func searchUsers(keyword: String, callBack: @escaping(Result<ExploreUsersResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.searchUsers.rawValue
        let params = ["keyword": keyword]
        
        service.httpRequest(url: url, method: APIRequestURLs.searchUsers.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<ExploreUsersResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func followUser(otherUserId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.followUser.rawValue
        let params = ["id": otherUserId]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.followUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func unfollowUser(otherUserId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.unFollowUser.rawValue
        let params = ["id": otherUserId]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.unFollowUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func likeUser(otherUserId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.likeUser.rawValue
        let params = ["otherUserId": otherUserId]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.likeUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func unlikeUser(otherUserId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.unlikeUser.rawValue
        let params = ["otherUserId": otherUserId]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.unlikeUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func blockUser(otherUserId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.blockUser.rawValue
        let params = ["otherUserId": otherUserId]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.blockUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func unblockUser(otherUserId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.unblockUser.rawValue
        let params = ["otherUserId": otherUserId]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.unblockUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func reportUser(otherUserId: Int, reason: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.reportUser.rawValue
        let params: [String: Any] = ["userId": otherUserId, "reason": reason]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.reportUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getBlockUsers(callBack: @escaping(Result<[ListUser], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getBlockUsers.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getBlockUsers.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<[ListUser]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func changePhone(areaCode: String, phone: String, smsCode: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.changePhone.rawValue
        let params = ["areaCode": areaCode,
                      "phoneNumber": phone,
                      "smsCode": smsCode]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.changePhone.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func changeEmail(newEmail: String, emailCode: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.changeEmail.rawValue
        let params = ["email": newEmail,
                      "emailCode": emailCode]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.changeEmail.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func changePassword(oldPassword: String, password: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.changePassword.rawValue
        let params = ["oldPassword": oldPassword,
                      "password": password]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.changePassword.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func switchPreferredAccount(newAccount: WalletType, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.switchPreferredAccount.rawValue
        let params = ["newAccount": newAccount.rawValue]
        
        service.httpRequestSimple(url: url, method: APIRequestURLs.switchPreferredAccount.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getFollowedSchedules(params: ExploreSchedulesParams, callBack: @escaping(Result<ExploreSchedulesResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.followedSchedules.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.followedSchedules.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<ExploreSchedulesResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func exploreSchedules(params: ExploreSchedulesParams, callBack: @escaping(Result<ExploreSchedulesResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.exploreSchedules.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.exploreSchedules.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<ExploreSchedulesResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func searchSchedules(keyword: String, callBack: @escaping(Result<[Schedule], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.searchSchedules.rawValue
        let params = ["keyword": keyword]
        
        service.httpRequest(url: url, method: APIRequestURLs.searchSchedules.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[Schedule]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func createSchedule(params: CreateScheduleParams, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.createSchedule.rawValue
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.createSchedule.getHTTPMethod(),
                                  parameters: params.params(),
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func updateSchedule(params: UpdateScheduleParams, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.updateSchedule.rawValue
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.updateSchedule.getHTTPMethod(),
                                  parameters: params.params(),
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func bookSchedule(scheduleId: Int, comment: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.bookSchedule.rawValue
        let params: [String: Any] = ["scheduleId": scheduleId, "comment": comment]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.bookSchedule.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func approveBooking(scheduleId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.approveBooking.rawValue
        let params = ["scheduleId": scheduleId]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.approveBooking.getHTTPMethod(),
                                  parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func denyBooking(comment: String, scheduleId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.denyBooking.rawValue
        let params: [String: Any] = ["comment": comment, "scheduleId": scheduleId]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.denyBooking.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func deleteSchedule(scheduleId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.deleteSchedule.rawValue
        let params = ["deleteId": scheduleId]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.deleteSchedule.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getUserSchedules(userId: Int? = nil, callBack: @escaping(Result<[Schedule], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getUserSchedules.rawValue
        var params: [String: Any]?
        if let userId = userId {
            params = ["userId": userId]
        }
        
        service.httpRequest(url: url,
                            method: APIRequestURLs.getUserSchedules.getHTTPMethod(),
                            parameters: params,
                            headers: Headers.defaultHeader()) { (result: AFResult<[Schedule]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getMyBookedSchedules(callBack: @escaping(Result<[Schedule], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyBookedSchedules.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getMyBookedSchedules.getHTTPMethod(), headers: Headers.defaultHeader()) { (result: AFResult<[Schedule]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getFavoriteSchedules(callBack: @escaping(Result<[Schedule], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getFavoriteSchedules.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getFavoriteSchedules.getHTTPMethod(), headers: Headers.defaultHeader()) { (result: AFResult<[Schedule]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func followOrUnfollowSchedule(scheduleId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.followOrUnfollowSchedule.rawValue
        let params: [String: Any] = ["scheduleId": scheduleId]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.followOrUnfollowSchedule.getHTTPMethod(),
                                  parameters: params, headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func guestCancelBooking(comment: String, scheduleId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.guestCancelBooking.rawValue
        let params: [String: Any] = ["comment": comment, "scheduleId": scheduleId]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.guestCancelBooking.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func hostCanceledBooking(comment: String, scheduleId: Int, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.hostCanceledBooking.rawValue
        let params: [String: Any] = ["comment": comment, "scheduleId": scheduleId]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.hostCanceledBooking.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getHistorySchedules(userId: Int?, callBack: @escaping(Result<[Schedule], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getHistorySchedules.rawValue
        
        var params: [String: Any]? = nil
        if let userId = userId {
            params = ["userId": userId]
        }
        
        service.httpRequest(url: url, method: APIRequestURLs.getHistorySchedules.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[Schedule]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getHostedSchedules(callBack: @escaping(Result<[Schedule], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getHostedSchedules.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getHostedSchedules.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<[Schedule]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getSchedule(scheduleId: Int, callBack: @escaping(Result<Schedule, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getSchedule.rawValue
        let params: [String: Any] = ["scheduleId": scheduleId]
        
        service.httpRequest(url: url, method: APIRequestURLs.getSchedule.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<Schedule>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func updateStatus(scheduleId: Int, status: ScheduleStatus,callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.updateStatus.rawValue
        let params: [String: Any] = ["id": scheduleId, "newStatus": status.rawValue]
        
        service.httpRequest(url: url, method: APIRequestURLs.updateStatus.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getRtcToken(scheduleId: Int, callBack: @escaping(Result<RTCTokenResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getRtcToken.rawValue
        let params: [String: Any] = ["scheduleId": scheduleId]
        
        service.httpRequest(url: url, method: APIRequestURLs.getRtcToken.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<RTCTokenResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func rejoinRoom(scheduleId: Int, callBack: @escaping(Result<RTCTokenResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.rejoinRoom.rawValue
        let params: [String: Any] = ["scheduleId": scheduleId]
        
        service.httpRequest(url: url, method: APIRequestURLs.rejoinRoom.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<RTCTokenResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getLog(scheduleId: Int, status: ScheduleStatus, fromUser: Int, toUser: Int, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getLog.rawValue
        let params: [String: Any] = ["scheduleId": scheduleId, "scheduleStatus": status.rawValue, "fromUser": fromUser, "toUser": toUser]
        
        service.httpRequest(url: url, method: APIRequestURLs.getLog.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getActionLog(otherUser: Int, callBack: @escaping(Result<[ActionLog], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getLogs.rawValue
        let params: [String: Any] = ["otherUser": otherUser]
        
        service.httpRequest(url: url, method: APIRequestURLs.getLogs.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[ActionLog]>) in
            switch result {
            case .success(let response):
                let filtered = response.filter { subject in
                    return !subject.logDescription().isEmpty
                }
                callBack(.success(filtered))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getTemplates(callBack: @escaping(Result<[Template], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getTemplates.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getTemplates.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<[Template]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func duplicateTemplate(templateId: Int, callBack: @escaping(Result<[Template], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.duplicateTemplate.rawValue
        let params = ["templateId": templateId]
        
        service.httpRequest(url: url, method: APIRequestURLs.duplicateTemplate.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[Template]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func deleteTemplate(templateId: Int, callBack: @escaping(Result<[Template], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.deleteTemplate.rawValue
        let params = ["templateId": templateId]
        
        service.httpRequest(url: url, method: APIRequestURLs.deleteTemplate.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[Template]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getAllReviews(userId: Int, reviewType: ReviewType?, callBack: @escaping(Result<[Review], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getReceivedReviews.rawValue
        var params: [String : Any] = ["userId": userId]
        if let reviewType = reviewType {
            params["reviewType"] = reviewType.rawValue
        }
        
        service.httpRequest(url: url, method: APIRequestURLs.getReceivedReviews.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[Review]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func postReview(param: CreateReviewParams, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.postReview.rawValue
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.postReview.getHTTPMethod(),
                                  parameters: param.params(),
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func updateReview(param: UpdateReviewParams, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.updateReview.rawValue
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.updateReview.getHTTPMethod(),
                                  parameters: param.params(),
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getTransactionHistory(callBack: @escaping(Result<[Transaction], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getTransactionHistory.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getLog.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<[Transaction]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func tipUser(userId: Int, amount: Int, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.tipUser.rawValue
        let params: [String : Any] = ["userId": userId, "amount": amount]
        
        service.httpRequest(url: url, method: APIRequestURLs.tipUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getLatestMessage(callBack: @escaping(Result<[Message], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getLatestMessage.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getLatestMessage.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<[Message]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getChatMessage(userId: Int, callBack: @escaping(Result<[Message], AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMessage.rawValue
        let params: [String : Any] = ["otherId": userId]
        
        service.httpRequest(url: url, method: APIRequestURLs.getMessage.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[Message]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func saveChatMessage(scheduleId: Int?, toUser: Int, userMessage: String, callBack: @escaping(Result<Message, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveChatMessage.rawValue
        var params: [String: Any] = ["toUser": toUser, "userMessage": userMessage]
        if let scheduleId = scheduleId {
            params["scheduleId"] = scheduleId
        }
        
        service.httpRequest(url: url, method: APIRequestURLs.saveChatMessage.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<Message>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func saveToken(token: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveToken.rawValue
        let params: [String : Any] = ["token": token, "tokenType": "ios"]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.saveToken.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func removeDeviceToken(token: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.removeDeviceToken.rawValue
        let params: [String : Any] = ["token": token, "tokenType": "ios"]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.removeDeviceToken.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func postFeedback(title: String, feedback: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.postFeedback.rawValue
        let params: [String : Any] = ["title": title, "feedback": feedback]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.postFeedback.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func clearBadgeCount(callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.clearBadgeCount.rawValue
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.clearBadgeCount.getHTTPMethod(),
                                  parameters: nil,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func setActivate(callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.setActivate.rawValue

        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.setActivate.getHTTPMethod(),
                                  parameters: [:],
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func chargeNew(packageOption: String, callBack: @escaping(Result<ChargeNewResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.chargeNew.rawValue
        let params: [String : Any] = ["currency": "cad", "description": "test", "packageOption": packageOption]
        
        service.httpRequest(url: url, method: APIRequestURLs.chargeNew.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<ChargeNewResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func cashOut(email: String,
                 emailMessage: String,
                 emailSubject: String,
                 coins: Int,
                 callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.cashOut.rawValue
        let params: [String : Any] = ["email": email, "emailMessage": emailMessage, "emailSubject": emailSubject, "coins": coins]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.cashOut.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
}
