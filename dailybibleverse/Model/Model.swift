//
//  Model.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 Agustin Bivachi. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Model {
    init(_ json: JSON)
    var parameters: [String: String]? { get }
}

extension Model {
    var parameters: [String: String]? {
        return nil
    }
}
