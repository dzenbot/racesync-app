//
//  UserApi.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-14.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Interface
public protocol UserApiInterface {

    /**
     Gets the authenticated User's profile information.

     - parameter completion: The closure to be called upon completion. Returns a transcient object containing the profile information of the authenticated User.
     */
    func getMyUser(_ completion: @escaping ObjectCompletionBlock<User>)

    /**
     Updates the home chapter on the authenticated User's profile.

     - parameter homeChapterId: The chapter id of the new User's home chapter.
     - parameter completion: The closure to be called upon completion. Returns a transcient object containing the profile information of the authenticated User.
     */
    func updateMyHomeChapter(with chapterId: ObjectId, completion: @escaping ObjectCompletionBlock<User>)

    /**
     */
    func getUser(with id: String, _ completion: @escaping ObjectCompletionBlock<User>)

    /**
     */
    func searchUser(with name: String, _ completion: @escaping ObjectCompletionBlock<User>)

    /**
     */
    func getUsers(forChapter chapterId: String, _ completion: @escaping ObjectCompletionBlock<[User]>)
}

public class UserApi: UserApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyUser(_ completion: @escaping ObjectCompletionBlock<User>) {

        let endpoint = EndPoint.userProfile

        repositoryAdapter.getObject(endpoint, type: User.self) { (user, error) in
            if user != nil { APIServices.shared.myUser = user }
            completion(user, error)
        }
    }

    public func updateMyHomeChapter(with chapterId: ObjectId, completion: @escaping ObjectCompletionBlock<User>) {

        let endpoint = EndPoint.userUpdateProfile
        let parameters: Params = [ParamKey.homeChapterId: chapterId]

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: User.self) { (user, error) in
            if user != nil { APIServices.shared.myUser = user }
            completion(user, error)
        }
    }

    public func getUser(with id: String, _ completion: @escaping ObjectCompletionBlock<User>) {

        let endpoint = EndPoint.userSearch
        let parameters: Params = [ParamKey.id: id]

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: User.self, completion)
    }

    public func searchUser(with username: String, _ completion: @escaping ObjectCompletionBlock<User>) {

        let endpoint = EndPoint.userSearch
        let parameters: Params = [ParamKey.userName: username]

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: User.self, completion)
    }

    @available(*, deprecated, message: "Not implemented by the API yet. See https://github.com/mainedrones/racesync-api/issues/16")
    public func getUsers(forChapter chapterId: String, _ completion: @escaping ObjectCompletionBlock<[User]>) {
        //
    }
}
