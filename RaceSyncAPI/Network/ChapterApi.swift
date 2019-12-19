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


    func getLocalChapters(currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Chapter]>)
}

public class ChapterApi: ChapterApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getChapters(forUser pilotId: String, currentPage: Int = 0, pageSize: Int = 25, _ completion: @escaping ObjectCompletionBlock<[Chapter]>) {

        let endPoint = EndPoint.chapterList
        var parameters: Parameters = [:]
        parameters[ParameterKey.joined] = [ParameterKey.pilotId : pilotId]

        repositoryAdapter.getObjects(endPoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Chapter.self, completion)
    }

    public func getLocalChapters(currentPage: Int = 0, pageSize: Int = 25, completion: @escaping ObjectCompletionBlock<[Chapter]>) {

        let endPoint = EndPoint.chapterFindLocal
        let parameters = parametersForMyLocalChapters()

        repositoryAdapter.getObjects(endPoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Chapter.self, completion)
    }
}

fileprivate extension ChapterApi {

    func parametersForMyLocalChapters() -> Parameters {
        var parameters: Parameters = [:]

        guard let myUser = APIServices.shared.myUser else { return parameters }

        parameters[ParameterKey.latitude] = myUser.latitude
        parameters[ParameterKey.longitude] = myUser.longitude
        parameters[ParameterKey.radius] = "500"
        return parameters
    }
}
