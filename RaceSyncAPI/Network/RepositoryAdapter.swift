//
//  RepositoryAdapter.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-24.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Alamofire
import ObjectMapper

class RepositoryAdapter {

    let networkAdapter = NetworkAdapter(serverUri: APIServices.shared.environment.baseURL)

    func getObject<Element: Mappable>(_ endPoint: String, parameters: Parameters? = nil, type: Element.Type, _ completion: @escaping ObjectCompletionBlock<Element>) {
        
        networkAdapter.httpRequest(endPoint, method: .post, parameters: parameters) { (request) in
            print("Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseObject(keyPath: ParameterKey.data, completionHandler: { (response: DataResponse<Element>) in
                switch response.result {
                case .success(let object):
                    completion(object, nil)
                case .failure:
                    let error = ErrorUtil.parseError(response)
                    print("network error \(error.debugDescription)")
                    completion(nil, error)
                }
            })
        }
    }

    func getObjects<Element: Mappable>(_ endPoint: String, parameters: Parameters? = nil, currentPage: Int = 0, pageSize: Int = 25, type: Element.Type, _ completion: @escaping ObjectCompletionBlock<[Element]>) {

        let endpoint = "\(endPoint)?\(ParameterKey.currentPage)=\(currentPage)&\(ParameterKey.pageSize)=\(pageSize)"

        networkAdapter.httpRequest(endpoint, method: .post, parameters: parameters) { (request) in
            print("Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")

            request.responseArray(keyPath: ParameterKey.data, completionHandler: { (response: DataResponse<[Element]>) in
                print("Ended request with code \(String(describing: response.response?.statusCode))")

                // patch for when lists are empty
                switch response.value {
                case .none:
                    completion([], nil); return
                default:
                    break
                }

                switch response.result {
                case .success(let objects):
                    completion(objects, nil)
                case .failure:
                    let error = ErrorUtil.parseError(response)
                    print("network error \(error.debugDescription)")
                    completion(nil, error)
                }
            })
        }
    }
}
