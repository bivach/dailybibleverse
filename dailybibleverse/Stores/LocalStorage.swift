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

//    private let coreDataHelper = CoreDataStack.sharedInstance

    private var userDefaults: UserDefaults { return UserDefaults.standard }

    // MARK: - Public Methods

//    // MARK: - Core Data
//
//    func newObject<T: NSManagedObject>() -> T {
//        let typeString = "\(T.self)"
//        let newObject =  coreDataHelper.newObjectWithType(typeString) as! T
//        return newObject
//    }
//
//    func storeObject(_ object: NSManagedObject) {
//        coreDataHelper.saveContext()
//    }
//
//    /// let array: [Instrument] = storedObjets()
//    func storedObjects<T: NSManagedObject>() -> [T] {
//        let typeString = "\(T.self)"
//        let objects: [T] = coreDataHelper.objectsWithType(typeString)
//        return objects
//    }
//
//    func deleteObject(_ object: NSManagedObject) {
//        coreDataHelper.deleteObject(object)
//    }

    // MARK: - Favorites

    func getFavorites() -> JSON? {
        if let configJson = userDefaults.string(forKey: favoritesKey) {
            return JSON(parseJSON: configJson)
        }
        return nil
    }

    func saveFavorites(_ favoriresJSON: JSON) {
        if let favoriresString = favoriresJSON.rawString([:]) {
            userDefaults.set(favoriresString, forKey: favoritesKey)
            userDefaults.synchronize()
        }
    }

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
    
    //MARK: DidTranslationChange
    
    func setDidTranslationChange(_ bool: Bool) {
        userDefaults.set(bool, forKey: didTranslationChange)
        userDefaults.synchronize()
    }
    
    func getDidTranslationChange() -> Bool {
        return userDefaults.object(forKey: didTranslationChange) as? Bool ?? false
    }
}
