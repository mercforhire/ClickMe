//
//  APIRequestsURLs.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-28.
//

import Foundation
import Alamofire

enum APIRequestURLs: String {
    case getEmailCode = "/api/users/authentication/getEmailCode"
    case refreshToken = "/api/users/authentication/refreshToken"
    case signInWithEmail = "/api/users/authentication/signInWithEmail"
    case signUpWithEmail = "/api/users/authentication/signUpWithEmail"
    
    case getCompleteUser = "/api/users/dataquery/secure/getOwnUserProfile"
    case exploreUsers = "/api/users/dataquery/secure/exploreUsers"
    case followUser = "/api/users/dataquery/secure/followUser"
    case getFollowees = "/api/users/dataquery/secure/getFollowees"
    case getFollowers = "/api/users/dataquery/secure/getFollowers"
    case unFollowUser = "/api/users/dataquery/secure/unFollowUser"
    case getUser = "/api/users/dataquery/secure/getUser"
    case blockUser = "/api/users/dataquery/secure/blockUser"
    case unblockUser = "/api/users/dataquery/secure/unblockUser"
    case searchUsers = "/api/users/dataquery/secure/searchUser"
    case reportUser = "/api/users/dataquery/secure/reportUser"
    case tipUser = "/api/users/dataquery/secure/tipUser"
    case getBlockUsers = "/api/users/dataquery/secure/getBlockUsers"
    
    case followSchedule = "/api/users/account_update/secure/followSchedule"
    case unfollowSchedule = "/api/users/account_update/secure/unfollowSchedule"
    case followedSchedules = "/api/schedules/secure/getFollowedSchedules"
    case getMyBookedSchedules = "/api/schedules/secure/getMyBookedSchedules"
    case getFavoriteSchedules = "/api/schedules/secure/getFavoriteSchedules"
    case exploreSchedules = "/api/schedules/exploreSchedules"
    case getUserSchedules = "/api/schedules/secure/getUserSchedules"
    case createSchedule = "/api/schedules/secure/createSchedule"
    case updateSchedule = "/api/schedules/secure/updateSchedule"
    case deleteSchedule = "/api/schedules/secure/deleteSchedule"
    case searchSchedules = "/api/schedules/secure/searchSchedules"
    case guestCancelBooking = "/api/schedules/secure/guestCancelBooking"
    case hostCanceledBooking = "/api/schedules/secure/hostCanceledBooking"
    case getHistorySchedules = "/api/schedules/secure/getHistorySchedules"
    case getHostedSchedules = "/api/schedules/secure/getHostedSchedules"
    case getSchedule = "/api/schedules/secure/getSchedule"
    case getLog = "/api/schedules/secure/getLog"
    case getLogs = "/api/schedules/secure/getLogs"
    case rejoinRoom = "/api/schedules/secure/rejoinRoom"
    
    case updateStatus = "/api/schedules/secure/updateStatus"
    case getRtcToken = "/api/schedules/secure/getRtcToken"
    
    case getTransactionHistory = "/api/users/dataquery/secure/getTransactionHistory"
    
    case getLatestMessage = "/api/chat_message/getLatestMessage"
    case getMessage = "/api/chat_message/getMessage"
    case saveChatMessage = "/api/chat_message/saveChatMessage"
    
    case approveBooking = "/api/schedules/secure/approveBooking"
    case denyBooking = "/api/schedules/secure/denyBooking"
    case bookSchedule = "/api/schedules/secure/bookSchedule"
    
    case getReceivedReviews = "/api/review/secure/getReceivedReviews"
    case postReview = "/api/review/secure/postReview"
    case updateReview = "/api/review/secure/updateReview"
    
    case getTemplates = "/api/schedules/secure/getTemplates"
    case duplicateTemplate = "/api/schedules/secure/duplicateTemplate"
    case deleteTemplate = "/api/schedules/secure/deleteTemplate"
    
    case updateProfile = "/api/users/account_update/secure/update"
    case uploadPhotos = "/api/users/account_update/secure/uploadPhotos"
    case deletePhotos = "/api/users/account_update/secure/deletePhotos"
    case deleteVideo = "/api/users/account_update/secure/deleteVideo"
    case uploadVideo = "/api/users/account_update/secure/uploadVideo"
    case changeEmail = "/api/users/account_update/secure/changeEmail"
    
    case postFeedback = "/api/feedback/secure/postFeedback"
    case getFeedbacks = "/api/feedback/secure/getFeedbacks"
    
    case saveToken = "/api/users/account_update/secure/saveToken"
    case removeDeviceToken = "/api/users/account_update/secure/removeDeviceToken"
    case clearBadgeCount = "/api/users/account_update/secure/clearBadgeCount"
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .changeEmail:
            return .patch
        case .deletePhotos:
            return .delete
        case .deleteVideo:
            return .delete
        case .updateProfile:
            return .patch
        case .uploadPhotos:
            return .post
        case .uploadVideo:
            return .post
        case .getEmailCode:
            return .post
        
        case .refreshToken:
            return .post
        case .signInWithEmail:
            return .post

        case .signUpWithEmail:
            return .post

        case .exploreUsers:
            return .post
        case .followUser:
            return .post
        case .getFollowees:
            return .get
        case .getFollowers:
            return .get
        case .getUser:
            return .get
        case .unFollowUser:
            return .post
        case .getCompleteUser:
            return .get
        case .postFeedback:
            return .post
        case .exploreSchedules:
            return .post
        case .getUserSchedules:
            return .get
        case .createSchedule:
            return .post
        case .deleteSchedule:
            return .delete
        case .getTemplates:
            return .get
        case .duplicateTemplate:
            return .post
        case .deleteTemplate:
            return .delete
        case .updateSchedule:
            return .patch
        case .followedSchedules:
            return .post
        case .getFavoriteSchedules:
            return .get
        case .getMyBookedSchedules:
            return .get
        case .approveBooking:
            return .patch
        case .denyBooking:
            return .patch
        case .bookSchedule:
            return .post
        case .postReview:
            return .post
        case .updateReview:
            return .patch
        case .searchSchedules:
            return .post
        case .searchUsers:
            return .post
        case .blockUser:
            return .post
        case .unblockUser:
            return .post
        case .getFeedbacks:
            return .get
        case .getReceivedReviews:
            return .post
        case .reportUser:
            return .post
        case .followSchedule:
            return .post
        case .unfollowSchedule:
            return .post
        case .guestCancelBooking:
            return .patch
        case .hostCanceledBooking:
            return .patch
        case .getHistorySchedules:
            return .get
        case .getHostedSchedules:
            return .get
        case .getSchedule:
            return .get
        case .getLog:
            return .get
        case .updateStatus:
            return .patch
        case .getTransactionHistory:
            return .get
        case .getRtcToken:
            return .get
        case .tipUser:
            return .post
        case .getLatestMessage:
            return .get
        case .getMessage:
            return .get
        case .saveChatMessage:
            return .post
        case .saveToken:
            return .post
        case .removeDeviceToken:
            return .delete
        case .getLogs:
            return .get
        case .clearBadgeCount:
            return .patch
        case .rejoinRoom:
            return .post
        case .getBlockUsers:
            return .get
        }
    }
    
    static func needAuthToken(url: String) -> Bool {
        if url.contains(string: APIRequestURLs.getEmailCode.rawValue) ||
            url.contains(string: APIRequestURLs.signInWithEmail.rawValue) ||
            url.contains(string: APIRequestURLs.signUpWithEmail.rawValue) ||
            url.contains(string: APIRequestURLs.refreshToken.rawValue) {
            return false
        }
        return true
    }
}
