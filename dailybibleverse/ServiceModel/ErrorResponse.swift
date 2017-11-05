//
//  ErrorResponse.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2015 Emiliano Bivachi. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ErrorEnum: Error {
    case network(statusCode: Int)
    case parsing
    case unauthorize
    case notAccount
    case notLoggedIn
    case custom(String)
    case error(NSError)
    case failedToSaveOrder(orderId: String, userName: String, accountId: String, error: NSError)
    case intraDayParsing(offer: JSON)
    case other
    
    var domain: String {
        switch self {
        case .network(_): return "Network"
        case .parsing: return "Parsing"
        case .unauthorize: return "Unauthorize"
        case .notAccount: return "NotAccount"
        case .notLoggedIn: return "NotLoggedIn"
        case .custom(_): return "Custom"
        case .error(_): return "Error"
        case .failedToSaveOrder: return "error.talaris.save.order"
        case .intraDayParsing: return "IntraDayParsing"
        case .other: return "other"
        }
    }
    
    var code: Int {
        switch self {
        case .failedToSaveOrder: return 666
        default: return 555
        }
    }
    
    var info: [String: AnyObject] {
        switch self {
        case .intraDayParsing(let offer): return ["offerJson": offer.description as AnyObject]
        case .failedToSaveOrder(let orderId, let userName, let accountId, let error):
            return ["orden_id": orderId as AnyObject, "usuario": userName as AnyObject, "cuenta": accountId as AnyObject, "error": error.debugDescription as AnyObject]
        default: return [:]
        }
    }
    
    var nsError: NSError {
        switch self {
        case .error(let error): return error
        default: return NSError(domain: domain, code: code, userInfo: info)
        }
    }
}
