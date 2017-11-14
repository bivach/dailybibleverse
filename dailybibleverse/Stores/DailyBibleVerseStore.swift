//
//  DailyBibleVerseStore.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Emiliano Bivachi. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

import Foundation

class DailyBibleVerseStore : BaseStore {
    static let sharedStore = DailyBibleVerseStore()
    let sharedLocalStorage = LocalStorage.sharedInstance
    
    func getDailyVerseTranslateNIV() -> Observable<ScriptureData> {
        let route = Router.ScriptureData.getScriptureDataTranslate(getDateAndTanslationNIV())
        return observableRequest(route)
    }
    
    func getDailyVerseTranslateKJV() -> Observable<ScriptureData> {
        let route = Router.ScriptureData.getScriptureDataTranslate(getDateAndTanslationKJV())
        return observableRequest(route)
    }
    
    func getDailyVerse() -> Observable<MergeDailyVerseResponse> {
        return Observable.zip(getDailyVerseTranslateKJV(), getDailyVerseTranslateNIV()) {
            return MergeDailyVerseResponse(scriptureDataKJV: $0, scriptureDataNIV: $1)
        }
    }
    
    func getDateAndTanslationNIV() -> [String: Any] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        let parameter = [
            "scripture_date": result,
            "translation_id": 2
            ] as [String : Any]
        return parameter
    }
    
    func getDateAndTanslationKJV() -> [String: Any] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        let parameter = [
            "scripture_date": result,
            "translation_id": 1
            ] as [String : Any]
        return parameter
    }
    
}

class MergeDailyVerseResponse {
    
    var scriptureDataKJV : ScriptureData?
    var scriptureDataNIV : ScriptureData?
    
    init (scriptureDataKJV: ScriptureData, scriptureDataNIV: ScriptureData) {
        self.scriptureDataKJV = scriptureDataKJV
        self.scriptureDataNIV = scriptureDataNIV
    }
    
    func getScriptureDataKJV() -> ScriptureData {
        return self.scriptureDataKJV!
    }
    
    func getScriptureDataNIV() -> ScriptureData {
        return self.scriptureDataNIV!
    }
}
