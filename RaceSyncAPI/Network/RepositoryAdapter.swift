//
//  RepositoryAdapter.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-24.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

class RepositoryAdapter {

    let networkAdapter = NetworkAdapter(serverUri: MGPWeb.getUrl(for: .apiBase))

    func getObject<Element: Mappable>(_ endPoint: String, parameters: Parameters? = nil, type: Element.Type, _ completion: @escaping ObjectCompletionBlock<Element>) {
        
        networkAdapter.httpRequest(endPoint, method: .post, parameters: parameters) { (request) in
            print("+ Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseObject(keyPath: ParameterKey.data, completionHandler: { (response: DataResponse<Element>) in
                print("+ Ended request with code \(String(describing: response.response?.statusCode))")
                
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
                    print("network error \(error.debugDescription)")
                    completion(nil, error)
                }
            })
        }
    }

    func getObjects<Element: Mappable>(_ endPoint: String, parameters: Parameters? = nil, currentPage: Int = 0, pageSize: Int = StandardPageSize, type: Element.Type, _ completion: @escaping ObjectCompletionBlock<[Element]>) {

        let endpoint = "\(endPoint)?\(ParameterKey.currentPage)=\(currentPage)&\(ParameterKey.pageSize)=\(pageSize)"

        networkAdapter.httpRequest(endpoint, method: .post, parameters: parameters) { (request) in
            print("+ Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseArray(keyPath: ParameterKey.data, completionHandler: { (response: DataResponse<[Element]>) in
                var log: String = "+ Ended request with code \(String(describing: response.response?.statusCode)) "

                // patch for when lists are empty
                switch response.value {
                case .none:
                    log += "(0 objects)"
                    completion([], nil)
                    print("\(log)")
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

                print("\(log)")
            })
        }
    }

    func performAction(_ endPoint: String, parameters: Parameters? = nil, completion: @escaping StatusCompletionBlock) {
        networkAdapter.httpRequest(endPoint,  method: .post, parameters: parameters) { (request) in
            print("+ Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseJSON { (response) in
                print("+ Ended request with code \(String(describing: response.response?.statusCode))")

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let errors = ErrorUtil.errors(fromJSON: json) {
                        completion(false, errors.first)
                    } else {
                        completion(json[ParameterKey.status].bool ?? false, nil)
                    }
                case .failure:
                    completion(false, response.error as NSError?)
                }
            }
        }
    }
}
