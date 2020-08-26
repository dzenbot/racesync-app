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
    func getChapters(forUser userId: ObjectId, currentPage: Int, pageSize: Int, _ completion: @escaping ObjectCompletionBlock<[Chapter]>)

    /**
    */
    func getLocalChapters(currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Chapter]>)

    /**
     */
    func getChapter(with chapterId: ObjectId, _ completion: @escaping ObjectCompletionBlock<Chapter>)

    /**
     */
    func searchChapter(with name: String, _ completion: @escaping ObjectCompletionBlock<Chapter>)

    /**
     */
    func getChapterMembers(with chapterId: ObjectId, currentPage: Int, pageSize: Int, _ completion: @escaping ObjectCompletionBlock<[User]>)

    /**
    */
    func getMyManagedChapters(_ completion: @escaping ObjectCompletionBlock<[ManagedChapter]>)

    /**
     */
    func join(chapter chapterId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
    */
    func resign(chapter chapterId: ObjectId, completion: @escaping StatusCompletionBlock)
}

public class ChapterApi: ChapterApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getChapters(forUser userId: ObjectId, currentPage: Int = 0, pageSize: Int = StandardPageSize, _ completion: @escaping ObjectCompletionBlock<[Chapter]>) {

        let endpoint = EndPoint.chapterList
        var parameters: Parameters = [:]
        parameters[ParameterKey.joined] = [ParameterKey.pilotId : userId]

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Chapter.self, completion)
    }

    public func getLocalChapters(currentPage: Int = 0, pageSize: Int = StandardPageSize, completion: @escaping ObjectCompletionBlock<[Chapter]>) {

        let endpoint = EndPoint.chapterFindLocal
        let parameters = parametersForMyLocalChapters()

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Chapter.self, completion)
    }

    public func getChapter(with chapterId: ObjectId, _ completion: @escaping ObjectCompletionBlock<Chapter>) {

        let endpoint = EndPoint.chapterSearch
        let parameters: Parameters = [ParameterKey.id: chapterId]

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Chapter.self, completion)
    }

    public func searchChapter(with chapterName: String, _ completion: @escaping ObjectCompletionBlock<Chapter>) {

        let endpoint = EndPoint.chapterSearch
        let parameters: Parameters = [ParameterKey.chapterName: chapterName]

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Chapter.self, completion)
    }

    public func getChapterMembers(with chapterId: ObjectId, currentPage: Int = 0, pageSize: Int = StandardPageSize, _ completion: @escaping ObjectCompletionBlock<[User]>) {

        let endpoint = "\(EndPoint.chapterUsers)?\(ParameterKey.id)=\(chapterId)"

        repositoryAdapter.getObjects(endpoint, skipPagination: true, type: User.self, completion)
    }

    public func getMyManagedChapters(_ completion: @escaping ObjectCompletionBlock<[ManagedChapter]>) {

        let endpoint = EndPoint.chapterListManaged

        repositoryAdapter.getObjects(endpoint, type: ManagedChapter.self, keyPath: ParameterKey.managedChapters, completion)
    }

    public func join(chapter chapterId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.chapterJoin)?\(ParameterKey.id)=\(chapterId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func resign(chapter chapterId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.chapterResign)?\(ParameterKey.id)=\(chapterId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
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
