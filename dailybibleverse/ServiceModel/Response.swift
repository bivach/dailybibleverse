//
//  Response.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2015 Emiliano Bivachi. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ResponseModel: Model {
    
}

struct EmptyResponse: ResponseModel {
    
    var status: String = ""
    
    init(_ json: JSON) {}
    
}
