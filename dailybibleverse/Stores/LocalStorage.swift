//
//  LocalStorage.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Emiliano Bivachi. All rights reserved.
//

import Foundation
import SwiftyJSON

class LocalStorage {

    static let sharedInstance = LocalStorage()

    // MARK: - Private Properties

    private let timeReminderKey = "com.dailybible.timeReminder"
    private let bibleVersionKey = "com.dailybible.bibleVersion"
    private let hasReminderKey = "com.dailybible.hasReminder"
    private let favoritesKey = "com.dailybible.favorites"
    private let didTranslationChange = "com.dailybible.didTranslationChange"
    private let firstTimeLauchingApp = "com.dailybible.firstTimeLauchingApp"

    private var userDefaults: UserDefaults { return UserDefaults.standard }

    
    // MARK: - bibleVersionKey

    func saveBibleVersion(_ bibleVersion: Int) {
        userDefaults.set(bibleVersion, forKey: bibleVersionKey)
        userDefaults.synchronize()
    }

    func getBibleVersion() -> Int {
        return userDefaults.object(forKey: bibleVersionKey) as? Int ?? 2
    }

    // MARK: - TimeReminder

    func saveHasReminder(_ hasReminder: Bool) {
        userDefaults.set(hasReminder, forKey: hasReminderKey)
        userDefaults.synchronize()
    }

    func getHasReminder() -> Bool {
        return userDefaults.object(forKey: hasReminderKey) as? Bool ?? false
    }
    
    func saveTimeReminderKey(_ timeReminder: String) {
        userDefaults.set(timeReminder, forKey: timeReminderKey)
        userDefaults.synchronize()
    }
    
    func getTimeReminderKey() -> String {
        return userDefaults.object(forKey: timeReminderKey) as? String ?? "08:00"
    }
    
    //MARK: DidTranslationChange
    
    func setDidTranslationChange(_ bool: Bool) {
        userDefaults.set(bool, forKey: didTranslationChange)
        userDefaults.synchronize()
    }
    
    func getDidTranslationChange() -> Bool {
        return userDefaults.object(forKey: didTranslationChange) as? Bool ?? false
    }
    
    //MARK: IsFirstTimeUserLaunchingApp
    
    func saveFirstTimeLaunchingApp(_ firstTime: Bool) {
        userDefaults.set(firstTime, forKey: firstTimeLauchingApp)
        userDefaults.synchronize()
    }
    
    func getFirstTimeLaunchingApp() -> Bool {
        return userDefaults.object(forKey: firstTimeLauchingApp) as? Bool ?? true
    }
    
}
