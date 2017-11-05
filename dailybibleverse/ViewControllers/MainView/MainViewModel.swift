//
//  MainViewModel.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Emiliano Bivachi. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift



class MainViewModel: NSObject {
    
    // MARK: - StateViewModel State
    
    
    enum State {
        case loading
        case error
        case success(ScriptureData)
    }
    
    var state: Variable<State> = Variable(.loading)
    
    var disposeBag = DisposeBag()
    
    let dailyBibleVerseStore = DailyBibleVerseStore.sharedStore
    
    var onChangeState: (MainViewModel.State) -> Void = { (state) in }
    
    func loadDailyVerse() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        dailyBibleVerseStore.getDailyVerse(result: result)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] scriptureData in
                self?.state.value = .success(scriptureData)
                }, onError: { error in
                    self.state.value = .error
                    print(error.localizedDescription)
            }).addDisposableTo(disposeBag)
        
    }
    
    func addOrDeleteScriptureFromRealm(scriptureData : ScriptureData) -> Bool {

        
        let realm = try! Realm()
        let scripts =  realm.objects(ScriptureRealm.self).filter("scripture_date == '\(scriptureData.scripture_date!)'")
        
        if (scripts.count > 0) {
                try! realm.write {
                    realm.delete(scripts.first!)
                }
            return false
        } else {
            addScriptureToRealm()
            return true
        }
        
    }
    
    func delete(scripts : RealmSwift.Results<ScriptureRealm>) {
        
    }
    
    func addScriptureToRealm() {
        if case .success(let scriptureData) = state.value {
            let favorite = ScriptureRealm()
            favorite.book_id = scriptureData.book_id
            favorite.book_name = scriptureData.book_name
            favorite.chapter = scriptureData.chapter
            favorite.scripture_date = scriptureData.scripture_date
            favorite.share_link = scriptureData.share_link
            favorite.span = scriptureData.span
            favorite.translation_id = scriptureData.translation_id
            favorite.tweet = scriptureData.tweet
            favorite.verse_end = scriptureData.verse_end
            favorite.verse_start = scriptureData.verse_start
            favorite.verses = scriptureData.verses.first?.verse_text
            favorite.verse_number = scriptureData.verses.first?.verse_no
            
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(favorite,update: true)
            }
        }
     }
}
