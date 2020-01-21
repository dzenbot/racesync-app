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
    func login(_ username: String, password: String, _ completion: @escaping CompletionBlock)

    /**
     Basic account log out method.

     - parameter completion: The closure to be called upon completion
     */
    func logout(_ completion: @escaping CompletionBlock)
}

public class AuthApi {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func login(_ username: String, password: String, _ completion: @escaping CompletionBlock) {

        let endpoint = EndPoint.userLogin
        let parameters: Parameters = [
            ParameterKey.username: username,
            ParameterKey.password: password
        ]

        repositoryAdapter.networkAdapter.httpRequest(endpoint, method: .post, parameters: parameters, nestParameters: false) { (request) in
            request.responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    APISessionManager.handleSessionJSON(json)
                    APISessionManager.setSessionEmail(username)
                    completion(nil)
                case .failure:
                    completion(ErrorUtil.parseError(response))
                }
            })
        }
    }

    public func logout(_ completion: @escaping CompletionBlock) {

        let endpoint = EndPoint.userLogout

        repositoryAdapter.networkAdapter.httpRequest(endpoint, method: .post) { (request) in
            request.responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    completion(nil)
                case .failure:
                    completion(ErrorUtil.parseError(response))
                }
            })
        }
    }
}
