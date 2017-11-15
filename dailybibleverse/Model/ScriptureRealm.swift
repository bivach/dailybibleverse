//
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Agustin Bivachi. All rights reserved.
//

import Foundation
import RealmSwift

class ScriptureRealm : Object {
    
    public var translation_id : Int? = 0
    public var scripture_date : String? = ""
    dynamic var book_id = 0
    dynamic var chapter = 0
    dynamic var verse_start = 0
    dynamic var verse_end = 0
    public var book_name : String? = ""
    public var verses : String? = ""
    public var verseKJV : String? = ""
    public var versesListNIV = List<VerseRealm>()
    public var versesListKJV = List<VerseRealm>()
    public var verseNIV : String? = ""
    public var span : String? = ""
    public var tweet : String? = ""
    public var share_link : String? = ""
    public var tweetNIV : String? = ""
    public var tweetKJV : String? = ""
    
    override class func primaryKey() -> String {
        return "scripture_date"
    }
    
    func setBookId(int : Int?) {
        self.book_id = int!
    }
    
    
}
