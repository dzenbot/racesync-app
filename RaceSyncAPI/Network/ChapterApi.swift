//
//  ChapterApi.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-21.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

public protocol ChapterApiInterface {

    /**
     */
    func getChapters(forUser pilotId: String, currentPage: Int, pageSize: Int, _ completion: @escaping ObjectCompletionBlock<[Chapter]>)

    /**
    */
    func getLocalChapters(currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Chapter]>)

    /**
     */
    func getChapter(with id: String, _ completion: @escaping ObjectCompletionBlock<Chapter>)

    /**
     */
    func getUsers(with id: String, currentPage: Int, pageSize: Int, _ completion: @escaping ObjectCompletionBlock<[User]>)

    /**
    */
    func getMyManagedChapters(_ completion: @escaping ObjectCompletionBlock<[ManagedChapter]>)
}

public class ChapterApi: ChapterApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getChapters(forUser pilotId: String, currentPage: Int = 0, pageSize: Int = StandardPageSize, _ completion: @escaping ObjectCompletionBlock<[Chapter]>) {

        let endpoint = EndPoint.chapterList
        var parameters: Parameters = [:]
        parameters[ParameterKey.joined] = [ParameterKey.pilotId : pilotId]

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Chapter.self, completion)
    }

    public func getLocalChapters(currentPage: Int = 0, pageSize: Int = StandardPageSize, completion: @escaping ObjectCompletionBlock<[Chapter]>) {

        let endpoint = EndPoint.chapterFindLocal
        let parameters = parametersForMyLocalChapters()

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Chapter.self, completion)
    }

    // TODO: Not implemented by the API yet. See https://github.com/MultiGP/racesync-api/issues/30
    public func getChapter(with id: String, _ completion: @escaping ObjectCompletionBlock<Chapter>) {

        let endpoint = "\(EndPoint.chapterList)?\(ParameterKey.id)=\(id)"

        repositoryAdapter.getObject(endpoint, type: Chapter.self, completion)
    }

    // TODO: Not implemented by the API yet. See https://github.com/MultiGP/racesync-api/issues/16
    public func getUsers(with id: String, currentPage: Int = 0, pageSize: Int = StandardPageSize, _ completion: @escaping ObjectCompletionBlock<[User]>) {

        let endpoint = EndPoint.chapterUsers
        var parameters: Parameters = [:]
        parameters[ParameterKey.chapterId] = id

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: User.self, completion)
    }

    public func getMyManagedChapters(_ completion: @escaping ObjectCompletionBlock<[ManagedChapter]>) {

        let endpoint = EndPoint.chapterListManaged

        repositoryAdapter.getObjects(endpoint, type: ManagedChapter.self, keyPath: ParameterKey.managedChapters, completion)
    }
}

fileprivate extension ChapterApi {

    func parametersForMyLocalChapters() -> Parameters {
        var parameters: Parameters = [:]

        guard let myUser = APIServices.shared.myUser else { return parameters }

        parameters[ParameterKey.latitude] = myUser.latitude
        parameters[ParameterKey.longitude] = myUser.longitude
        parameters[ParameterKey.radius] = APIServices.shared.settings.searchRadius
        return parameters
    }
}
