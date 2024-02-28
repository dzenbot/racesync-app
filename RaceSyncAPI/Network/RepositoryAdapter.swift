//
//  RepositoryAdapter.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-24.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SwiftyJSON

class RepositoryAdapter {

    let networkAdapter = NetworkAdapter(serverUri: MGPWeb.getUrl(for: .apiBase))

    func getObject<Element: Mappable>(_ endPoint: String, parameters: Params? = nil, type: Element.Type, keyPath: String = ParamKey.data, _ completion: @escaping ObjectCompletionBlock<Element>) {
        
        networkAdapter.httpRequest(endPoint, method: .post, parameters: parameters) { (request) in
            Clog.log("Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseObject(keyPath: keyPath, completionHandler: { (response: DataResponse<Element>) in
                Clog.log("Ended request with code \(String(describing: response.response?.statusCode))")

                if let code = response.response?.statusCode, code == 401 {
                    Clog.log("Detected 401. Should log out User!")
                }

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let errors = ErrorUtil.errors(fromJSON: json) {
                        completion(nil, errors.first)
                    } else {
                        completion(value, nil)
                    }
                case .failure:
                    let error = ErrorUtil.parseError(response)
                    Clog.log("Network error \(error.debugDescription)")
                    completion(nil, error)
                }
            })
        }
    }

    func getObjects<Element: Mappable>(_ endPoint: String, parameters: Params? = nil, currentPage: Int = 0, pageSize: Int = StandardPageSize, skipPagination: Bool = false, type: Element.Type, keyPath: String = ParamKey.data, _ completion: @escaping ObjectCompletionBlock<[Element]>) {

        var finalEndpoint = endPoint

        // only include pagination if required
        if !skipPagination {
            finalEndpoint = "\(endPoint)?\(ParamKey.currentPage)=\(currentPage)&\(ParamKey.pageSize)=\(pageSize)"
        }

        networkAdapter.httpRequest(finalEndpoint, method: .post, parameters: parameters) { (request) in
            Clog.log("Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseArray(keyPath: keyPath, completionHandler: { (response: DataResponse<[Element]>) in
                var log: String = "+ Ended request with code \(String(describing: response.response?.statusCode)) "

                if let code = response.response?.statusCode, code == 401 {
                    Clog.log("Detected 401. Should log out User!")
                }

                // patch for when lists are empty
                switch response.value {
                case .none:
                    log += "(0 objects)"
                    completion([], nil)
                    Clog.log("\(log)")
                    return
                default:
                    break
                }

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let errors = ErrorUtil.errors(fromJSON: json) {
                        completion(nil, errors.first)
                        log += " Network Error: \(errors.first.debugDescription)"
                    } else {
                        completion(value, nil)
                        log += "(\(value.count) objects)"
                    }
                case .failure:
                    let error = ErrorUtil.parseError(response)
                    completion(nil, error)
                    log += " Network Error: \(error.debugDescription)"
                }

                Clog.log("\(log)")
            })
        }
    }

    func performAction(_ endPoint: String, parameters: Params? = nil, completion: @escaping StatusCompletionBlock) {
        networkAdapter.httpRequest(endPoint,  method: .post, parameters: parameters) { (request) in
            Clog.log("Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseJSON { (response) in
                Clog.log("Ended request with code \(String(describing: response.response?.statusCode))")

                if let code = response.response?.statusCode, code == 401 {
                    Clog.log("Detected 401. Should log out User!")
                }

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let errors = ErrorUtil.errors(fromJSON: json) {
                        completion(false, errors.first)
                    } else {
                        completion(json[ParamKey.status].bool ?? false, nil)
                    }
                case .failure:
                    completion(false, response.error as NSError?)
                }
            }
        }
    }
}
