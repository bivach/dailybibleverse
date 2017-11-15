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
    let sharedLocalStorage = LocalStorage.sharedInstance;
    
    enum State {
        case loading
        case error
        case success(MergeDailyVerseResponse)
    }
    
    var state: Variable<State> = Variable(.loading)
    
    var disposeBag = DisposeBag()
    
    let dailyBibleVerseStore = DailyBibleVerseStore.sharedStore
    
    var onChangeState: (MainViewModel.State) -> Void = { (state) in }
    
    func loadDailyVerse() {
        dailyBibleVerseStore.getDailyVerse()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] mergeDailyVerseResponse in
                self?.state.value = .success(mergeDailyVerseResponse)
                }, onError: { error in
                    self.state.value = .error
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
    
    func addScriptureToRealm() {
        if case .success(let mergeDailyVerseResponse) = state.value {
            
            let scriptureData : ScriptureData = sharedLocalStorage.getBibleVersion() == 1 ? mergeDailyVerseResponse.getScriptureDataKJV() : mergeDailyVerseResponse.getScriptureDataNIV()
            
            let favorite = ScriptureRealm()
            favorite.book_id = scriptureData.book_id!
            favorite.book_name = scriptureData.book_name
            favorite.chapter = scriptureData.chapter!
            favorite.scripture_date = scriptureData.scripture_date
            favorite.share_link = scriptureData.share_link
            favorite.tweetNIV = mergeDailyVerseResponse.getScriptureDataNIV().tweet
            favorite.tweetKJV = mergeDailyVerseResponse.getScriptureDataKJV().tweet
            favorite.span = scriptureData.span
            favorite.translation_id = scriptureData.translation_id
            favorite.tweet = scriptureData.tweet
            favorite.verse_end = scriptureData.verse_end!
            favorite.verse_start = scriptureData.verse_start!
            favorite.verses = scriptureData.verses.first?.verse_text
            for verse in mergeDailyVerseResponse.getScriptureDataNIV().verses {
                let realmVerse = VerseRealm()
                realmVerse.verse_no = verse.verse_no!
                realmVerse.verse_text = verse.verse_text!
                favorite.versesListNIV.append(realmVerse)
            }
            for verse in mergeDailyVerseResponse.getScriptureDataKJV().verses {
                let realmVerse = VerseRealm()
                realmVerse.verse_no = verse.verse_no!
                realmVerse.verse_text = verse.verse_text!
                favorite.versesListKJV.append(realmVerse)
            }
            favorite.verseNIV = mergeDailyVerseResponse.getScriptureDataNIV().getFirtVerse()
            favorite.verseKJV = mergeDailyVerseResponse.getScriptureDataKJV().getFirtVerse()
            
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(favorite,update: true)
            }
        }
     }
}
