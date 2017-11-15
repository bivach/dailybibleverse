//
//  VerseRealm.swift
//  dailybibleverse
//
//  Created by Emiliano Bivachi on 14/11/17.
//  Copyright © 2017 adepture. All rights reserved.
//

import Foundation
import RealmSwift

class VerseRealm : Object {
    public var verse_no : Int = 0
    public var verse_text : String = ""
}
