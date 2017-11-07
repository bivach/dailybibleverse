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
    
    func getDailyVerse(result :String) -> Observable<ScriptureData> {
        let parameter = [
            "scripture_date": result,
            "translation_id": sharedLocalStorage.getBibleVersion()
            ] as [String : Any]
        let route = Router.ScriptureData.scriptureData(parameter)
        return observableRequest(route)
    }
    
    func getDailyVerseTranslate(id :Int) -> Observable<ScriptureData> {
        let parameter = [
            "translation_id": id
        ]
        let route = Router.ScriptureData.scriptureDataTranslate(parameter)
        return observableRequest(route)
    }
}
