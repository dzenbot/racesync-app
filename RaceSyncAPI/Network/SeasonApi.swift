//
//  SeasonApi.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-26.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Interface
public protocol SeasonApiInterface {

    /**
     */
    func getSeason(with seasonId: ObjectId, _ completion: @escaping ObjectCompletionBlock<Season>)

    /**
     */
    func searchSeason(with name: String, _ completion: @escaping ObjectCompletionBlock<Season>)

    /**
     */
    func getSeasons(forChapter chapterId: ObjectId, currentPage: Int, pageSize: Int, _ completion: @escaping ObjectCompletionBlock<[Season]>)

    /**
     */
    func createSeason(forChapter chapterId: ObjectId, with parameters: Parameters, _ completion: @escaping ObjectCompletionBlock<Season>)

    /**
     */
    func deleteSeason(with seasonId: ObjectId, _ completion: @escaping StatusCompletionBlock)
}

public class SeasonApi: SeasonApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getSeason(with seasonId: ObjectId, _ completion: @escaping ObjectCompletionBlock<Season>) {

        let endpoint = EndPoint.seasonSearch
        let params: Parameters = [ParameterKey.id: seasonId]

        repositoryAdapter.getObject(endpoint, parameters: params, type: Season.self, completion)
    }

    public func searchSeason(with name: String, _ completion: @escaping ObjectCompletionBlock<Season>) {

        let endpoint = EndPoint.seasonSearch
        let params: Parameters = [ParameterKey.name: name]

        repositoryAdapter.getObject(endpoint, parameters: params, type: Season.self, completion)
    }

    public func getSeasons(forChapter chapterId: ObjectId, currentPage: Int = 0, pageSize: Int = StandardPageSize, _ completion: @escaping ObjectCompletionBlock<[Season]>) {

        let endpoint = EndPoint.seasonList
        let params: Parameters = [ParameterKey.chapterId: chapterId]

        repositoryAdapter.getObjects(endpoint, parameters: params, currentPage: currentPage, pageSize: pageSize, type: Season.self, completion)
    }

    public func createSeason(forChapter chapterId: ObjectId, with parameters: Parameters, _ completion: @escaping ObjectCompletionBlock<Season>) {

        let endpoint = EndPoint.seasonCreate
        var params: Parameters = parameters
        params[ParameterKey.chapterId] = chapterId

        repositoryAdapter.getObject(endpoint, parameters: params, type: Season.self, completion)
    }

    public func deleteSeason(with seasonId: ObjectId, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = EndPoint.seasonDelete
        let params: Parameters = [ParameterKey.id: seasonId]

        repositoryAdapter.performAction(endpoint, parameters: params, completion: completion)
    }
}

fileprivate extension SeasonApi {

}
