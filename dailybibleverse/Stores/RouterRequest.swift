//
//  RouterRequest.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2016 Emiliano Bivachi. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - RouterURLRequestConvertible

protocol RouterRequest: URLConvertible {
    var baseURLString: String { get }
    var method: Alamofire.HTTPMethod { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var path: String { get }
    var cookiesHeader: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

// MARK: - RouterURLRequestConvertible default implementation

extension RouterRequest {
    
    var cookiesHeader: [String: String]? { return nil }
    
    var parameters: [String: Any]? { return nil }
    
    var encoding: Alamofire.ParameterEncoding { return URLEncoding.queryString }
    
    var URLString: String { return "\(baseURLString)\(path)" }
    
    var method: Alamofire.HTTPMethod { return .get }
    
    func asURL() throws -> URL { return Foundation.URL(string: URLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)! }
}
