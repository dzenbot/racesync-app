//
//  RaceApi.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// MARK: - Interface

public enum RaceListFiltering: String {
    case upcoming = "upcoming"
    case past = "past"
    case nearby = "nearby"
    case all = "all"
}

public protocol RaceApiInterface {

    /**
     Gets a filtered set of races related to the authenticated User.

     - parameter filtering: The amount filterying type, such as upcoming, past, nearby and all
     - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
     */
    func getMyRaces(filtering: RaceListFiltering, completion: @escaping ObjectCompletionBlock<[Race]>)

    /**
    Gets a filtered set of races related to a specific User.

    - parameter userId: The User id.
    - parameter filtering: The amount filterying type, such as upcoming, past, nearby and all
    - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
    */
    func getRaces(forUser userId: ObjectId, filtering: RaceListFiltering, latitude: String?, longitude: String?, currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Race]>)

    /**
    Gets the races belonging to a specific chapter.

    - parameter chapterId: The Chapter id.
    - parameter currentPage: The current page cursor position. Default is 0
    - parameter pageSize: The amount of objects to be returned by page. Default is 25.
    - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
    */
    func getRaces(forChapter chapterId: ObjectId, currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Race]>)

    /**
    Gets a full Race object, including pilot entries and schedule

     - parameter raceId: The Race id.
     - parameter completion: The closure to be called upon completion. Returns a transcient Race object.
    */
    func view(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>)

    /**
    Gets a full Race object, including pilot entries and excluding the schedule

     - parameter raceId: The Race id.
     - parameter completion: The closure to be called upon completion. Returns a transcient Race object.
    */
    func viewSimple(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>)

    /**
     */
    func join(race raceId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
     */
    func resign(race raceId: ObjectId, completion: @escaping StatusCompletionBlock)
}

public class RaceApi: RaceApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyRaces(filtering: RaceListFiltering, completion: @escaping ObjectCompletionBlock<[Race]>) {
        guard let myUser = APIServices.shared.myUser else { return }
        getRaces(forUser: myUser.id, filtering: filtering, latitude: myUser.latitude, longitude: myUser.longitude, completion: completion)
    }

    public func getRaces(forUser userId: ObjectId,
                         filtering: RaceListFiltering,
                         latitude: String? = nil, longitude: String? = nil,
                         currentPage: Int = 0, pageSize: Int = 25,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endPoint = EndPoint.raceList
        let parameters = parametersForRaces(with: userId, filtering: filtering, latitude: latitude, longitude: longitude)
        repositoryAdapter.getObjects(endPoint, parameters: parameters, type: Race.self, completion)
    }

    public func getRaces(forChapter chapterId: ObjectId,
                         currentPage: Int = 0, pageSize: Int = 25,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endPoint = EndPoint.raceList
        let parameters = [ParameterKey.chapterId: chapterId]

        repositoryAdapter.getObjects(endPoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Race.self) { (races, error) in
            completion(races, error)
        }
    }

    public func view(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>) {

        let endPoint = "\(EndPoint.raceView)?\(ParameterKey.id)=\(raceId)"
        repositoryAdapter.getObject(endPoint, type: Race.self, completion)
    }

    public func viewSimple(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>) {

        let endPoint = "\(EndPoint.raceViewSimple)?\(ParameterKey.id)=\(raceId)"
        repositoryAdapter.getObject(endPoint, type: Race.self, completion)
    }

    public func join(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceJoin)?\(ParameterKey.id)=\(raceId)"

        repositoryAdapter.networkAdapter.httpRequest(endpoint, method: .post) { (request) in
            print("Starting request \(String(describing: request.request?.url))")
            request.responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json[ParameterKey.status].bool ?? false, nil)
                case .failure:
                    completion(false, nil)
                }
            }
        }
    }

    public func resign(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {
        
        let endpoint = "\(EndPoint.raceResign)?\(ParameterKey.id)=\(raceId)"

        repositoryAdapter.networkAdapter.httpRequest(endpoint, method: .post) { (request) in
            print("Starting request \(String(describing: request.request?.url))")
            request.responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json[ParameterKey.status].bool ?? false, nil)
                case .failure:
                    completion(false, nil)
                }
            }
        }
    }
}

fileprivate extension RaceApi {

    func parametersForRaces(with userId: ObjectId,
                            filtering: RaceListFiltering,
                            latitude: String? = nil, longitude: String? = nil) -> Parameters {
        
        var parameters: Parameters = [:]

        if filtering == .nearby {
            parameters[ParameterKey.nearBy] = [
                ParameterKey.latitude: latitude,
                ParameterKey.longitude: longitude,
                ParameterKey.radius: "500"
            ]
        } else {
            parameters[ParameterKey.joined] = [ParameterKey.pilotId : userId]
            if filtering == .upcoming {
                // TODO: Disabling for now since it's causing the API to return an empty array every time
                // Bugged https://github.com/mainedrones/racesync-api/issues/14
                // parameters[ParameterKey.upcoming] = [ParameterKey.limit: 20, ParameterKey.orderByDistance: false]
            } else if filtering == .past {
                parameters[ParameterKey.past] = [ParameterKey.limit: 20, ParameterKey.orderByDistance: false]
            }
        }

        return parameters
    }
}
