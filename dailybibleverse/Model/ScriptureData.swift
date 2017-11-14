//
//  ScriptureData.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Agustin Bivachi. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScriptureData : ResponseModel {
    public let translation_id : Int?
    public let scripture_date : String?
    public let book_id : Int?
    public let chapter : Int?
    public let verse_start : Int?
    public let verse_end : Int?
    public let book_name : String?
    public var verses : [Verse]
    public let span : String?
    public let tweet : String?
    public let share_link : String?
    
    required init(_ json: JSON) {
        translation_id = json["translation_id"].int
        scripture_date = json["scripture_date"].stringValue
        book_id = json["book_id"].int
        chapter = json["chapter"].int
        verse_start = json["verse_start"].int
        verse_end = json["verse_end"].int
        book_name = json["book_name"].stringValue
        var verses = [Verse]()
        for verse in json["verses"].arrayValue {
            verses.append(Verse(verse))
        }
        self.verses = verses
        span = json["span"].stringValue
        tweet = json["tweet"].stringValue
        share_link = json["share_link"].stringValue
    }
    
    public func getFirtVerse() -> String {
        return "\(self.verses.first?.verse_no ?? 1)  " + (self.verses.first?.verse_text)!
    }
    
    
}
