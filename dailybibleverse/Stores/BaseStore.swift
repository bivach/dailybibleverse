//
//  BaseStore.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2015 Emiliano Bivachi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

internal let networkBackgroundQueue = DispatchQueue(label: "com.Adepture.DailyVerseBibleTest.NetworkingCompletionQueue", attributes: [])

class BaseStore {
    
    lazy var manager: Alamofire.SessionManager = {
        let manager = Alamofire.SessionManager.default
        manager.delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            if (response.allHeaderFields["Location"] as? String)?.contains("login") == true {
                return nil
            }
            return request
        }
        return manager
    }()
    
    func observableRequest<T: ResponseModel>(_ route: RouterRequest) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let request = self?.request(route).response(queue: networkBackgroundQueue) { dateResponse in
                //                debugPrint("-------------------------------------------------------------------------------------")
                //                debugPrint("---Request URL: ",dateResponse.request!.url!)
                //                debugPrint("---Request Headers URL: ",dateResponse.request!.allHTTPHeaderFields!)
                //                debugPrint("---Response URL: ",dateResponse.response!)
                //                debugPrint("---Response Headers URL: ",dateResponse.response!.allHeaderFields)
                //                debugPrint("-------------------------------------------------------------------------------------")
                
                if dateResponse.response?.statusCode == 302 {
                    observer.onError(ErrorEnum.unauthorize)
                } else if dateResponse.response?.url?.absoluteString.contains("error=true") == true {
                    observer.onError(ErrorEnum.unauthorize)
                } else if dateResponse.error != nil {
                    observer.onError(ErrorEnum.network(statusCode: dateResponse.response?.statusCode ?? 500))
                } else {
                    let responseObj: T
                    let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
                    let result = JSONResponseSerializer.serializeResponse(dateResponse.request, dateResponse.response, dateResponse.data, dateResponse.error)
                    if let value = result.value {
                        let json = JSON(value)
                        if let status = json["status"].string , status == "ERROR" {
                            observer.onError(ErrorEnum.custom(json["description"].string ?? json["message"].stringValue))
                        } else {
                            responseObj = T(json)
                            observer.onNext(responseObj)
                        }
                    } else {
                        observer.onError(ErrorEnum.parsing)
                    }
                    observer.onCompleted()
                }
            }
            return Disposables.create { request?.cancel() }
        }
    }
    
    private func request(_ route: RouterRequest) -> DataRequest {
        var httpHeaders: [String: String] = [:]
        if let cookiesHeader = route.cookiesHeader {
            httpHeaders = cookiesHeader
        }
        return manager.request(route, method: route.method, parameters: route.parameters, encoding: route.encoding, headers: httpHeaders)
    }
}
