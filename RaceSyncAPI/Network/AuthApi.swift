//
//  LoginAPI.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

// MARK: - Interface
public protocol AuthApiInterface {

    /**
     Simple account authentication using email/password. On success, the sessionId is persisted internally for later
     being used, in combination with the apiKey, on any future API calls.

     - parameter username: This can either be a username or email from MultiGP.com
     - parameter password: Account password.
     - parameter completion: The closure to be called upon completion
     */
    func login(_ username: String, password: String, _ completion: @escaping StatusCompletionBlock)

    /**
     Basic account log out method.

     - parameter completion: The closure to be called upon completion
     */
    func logout(_ completion: @escaping StatusCompletionBlock)
}

public class AuthApi {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func login(_ username: String, password: String, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = EndPoint.userLogin
        let parameters: Parameters = [
            ParameterKey.username: username,
            ParameterKey.password: password
        ]

        repositoryAdapter.networkAdapter.httpRequest(endpoint, method: .post, parameters: parameters, nestParameters: false) { (request) in
            Clog.log("Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseJSON(completionHandler: { (response) in
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
                        APISessionManager.handleSessionJSON(json)
                        APISessionManager.setSessionEmail(username)
                        completion(true, nil)
                    }
                case .failure:
                    completion(false, response.error as NSError?)
                }
            })
        }
    }

    public func logout(_ completion: @escaping StatusCompletionBlock) {

        let endpoint = EndPoint.userLogout

        repositoryAdapter.networkAdapter.httpRequest(endpoint, method: .post) { (request) in
            Clog.log("Starting request \(String(describing: request.request?.url)))")
            request.responseJSON(completionHandler: { (response) in
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
                        completion(true, nil)
                    }
                case .failure:
                    completion(false, response.error as NSError?)
                }
            })
        }
    }
}
