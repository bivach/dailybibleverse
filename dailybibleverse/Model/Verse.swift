//
//  Verse.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Agustin Bivachi. All rights reserved.
//

import Foundation
import SwiftyJSON

class Verse : Model {
    public var verse_no : Int?
    public var verse_text : String?
    
    required init(_ json: JSON) {
        verse_no = json["verse_no"].int
        verse_text = json["verse_text"].stringValue
    }
}
