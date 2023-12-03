//
//  AppSettingsManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation

enum Environments: String {
    case production
    case development
    
    func hostUrl() -> String {
        switch self {
        case .production:
            return "https://cpclickme.com"
        case .development:
            return "http://15.222.166.60"
        }
    }
}

class AppSettingsManager {
    static let shared = AppSettingsManager()
    
    private let AppSettingsKey : String = "AppSettings"
    private let EnvironmentKey : String = "Environment"
    private let GetStartedViewedKey : String = "GetStartedViewed"
    private let HasBeenToHostViewKey : String = "HasBeenToHostView"
    private let LastUsedAreaCodeKey : String = "LastUsedAreaCode"
    private let LastUsedPhoneKey : String = "LastUsedPhone"
    private let LastUsedEmailKey : String = "LastUsedEmail"
    private let LastUsedMode : String = "LastUsedMode"
    private let DeviceToken : String = "DeviceToken"
    private let LastSetActiveTime : String = "LastSetActiveTime"
    private let ViewedTutorialsMemoryKey : String = "ViewedTutorialsMemory"
    
    private let defaults = UserDefaults.standard
    private var settings: [String: Any] = [:]
    
    init() {
        loadSettingsFromPersistence()
    }
    
    private func loadSettingsFromPersistence() {
        //load previous Settings
        settings = defaults.dictionary(forKey: AppSettingsKey) ?? [:]
    }
    
    private func saveSettings() {
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
    
    func getEnvironment() -> Environments {
        return Environments(rawValue: (settings[EnvironmentKey] as? String) ?? "") ?? .production
    }
    
    func setEnvironment(environments: Environments) {
        settings[EnvironmentKey] = environments.rawValue
        saveSettings()
    }
    
    func isGetStartedViewed() -> Bool {
        return settings[GetStartedViewedKey] != nil
    }
    
    func setGetStartedViewed(viewed: Bool) {
        if viewed {
            settings[GetStartedViewedKey] = true
        } else {
            settings[GetStartedViewedKey] = nil
        }
        saveSettings()
    }
    
    func hasBeenToHostView() -> Bool {
        return settings[HasBeenToHostViewKey] != nil
    }
    
    func setHasBeenToHostView(been: Bool) {
        if been {
            settings[HasBeenToHostViewKey] = true
        } else {
            settings[HasBeenToHostViewKey] = nil
        }
        saveSettings()
    }
    
    func getLastUsedEmail() -> String? {
        return settings[LastUsedEmailKey] as? String
    }
    
    func setLastUsedEmail(email: String?) {
        settings[LastUsedEmailKey] = email
        saveSettings()
    }
    
    func getLastUsedAreaCode() -> String? {
        return settings[LastUsedAreaCodeKey] as? String
    }
    
    func setLastUsedAreaCode(areaCode: String?) {
        settings[LastUsedAreaCodeKey] = areaCode
        saveSettings()
    }
    
    func getLastUsedPhone() -> String? {
        return settings[LastUsedPhoneKey] as? String
    }
    
    func setLastUsedPhone(phone: String?) {
        settings[LastUsedPhoneKey] = phone
        saveSettings()
    }
    
    func getLastUsedMode() -> String? {
        return settings[LastUsedMode] as? String
    }
    
    func setLastUsedMode(mode: String?) {
        settings[LastUsedMode] = mode
        saveSettings()
    }
    
    func getDeviceToken() -> String? {
        return settings[DeviceToken] as? String
    }
    
    func setDeviceToken(token: String?) {
        settings[DeviceToken] = token
        saveSettings()
    }
    
    func getLastSetActiveTime() -> Date? {
        return settings[LastSetActiveTime] as? Date
    }
    
    func setLastSetActiveTime(date: Date) {
        settings[LastSetActiveTime] = date
        saveSettings()
    }
    
    func getViewedTutorialsMemory() -> [String: Bool]? {
        return settings[ViewedTutorialsMemoryKey] as? [String : Bool]
    }
    
    func setViewedTutorialsMemory(value: [String: Bool]?) {
        settings[ViewedTutorialsMemoryKey] = value
        saveSettings()
    }
    
    func resetSettings() {
        // don't forget the environment settings
        let current = getEnvironment()
        settings = [:]
        settings[EnvironmentKey] = current.rawValue
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
}
