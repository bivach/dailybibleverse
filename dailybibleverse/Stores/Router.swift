//
//  Router.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2015 Emiliano Bivachi. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Router

struct Router {
    
    
    // MARK: - Router.MarketData
    
    enum ScriptureData: RouterRequest {
        case scriptureData([String: Any])
        case scriptureDataTranslate([String: Int])
        
        var method: Alamofire.HTTPMethod {
            return .get
        }
        
        var baseURLString: String {
            return "https://www.yourdailybible.com"
        }
        
        var path: String {
                return "/scripture/GetScriptureRequest"
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .scriptureData(let parameters):
                return parameters
            case .scriptureDataTranslate(let parameters):
                return parameters
            }
        }
    }
    
}
