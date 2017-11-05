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
    public var book_id : Int? = 0
    public var chapter : Int? = 0
    public var verse_start : Int? = 0
    public var verse_end : Int? = 0
    public var book_name : String? = ""
    public var verses : String? = ""
    public var span : String? = ""
    public var tweet : String? = ""
    public var share_link : String? = ""
    public var verse_number : Int? = 0
    
    override class func primaryKey() -> String {
        return "scripture_date"
    }
    
}
