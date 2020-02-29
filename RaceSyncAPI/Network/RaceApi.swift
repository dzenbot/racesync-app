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
    func getMyRaces(filtering: RaceListFiltering, latitude: String?, longitude: String?, completion: @escaping ObjectCompletionBlock<[Race]>)

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
    func join(race raceId: ObjectId, aircraftId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
     */
    func resign(race raceId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
     */
    func open(race raceId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
     */
    func close(race raceId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
    */
    func checkIn(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<RaceEntry>)

    /**
    */
    func checkOut(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<RaceEntry>)
}

public class RaceApi: RaceApiInterface {

    public init() {}

    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyRaces(filtering: RaceListFiltering,
                           latitude: String? = nil,
                           longitude: String? = nil,
                           completion: @escaping ObjectCompletionBlock<[Race]>) {
        guard let myUser = APIServices.shared.myUser else { return }
        let lat = latitude ?? myUser.latitude
        let long = longitude ?? myUser.longitude
        getRaces(forUser: myUser.id, filtering: filtering, latitude: lat, longitude: long, completion: completion)
    }

    public func getRaces(forUser userId: ObjectId,
                         filtering: RaceListFiltering,
                         latitude: String? = nil, longitude: String? = nil,
                         currentPage: Int = 0, pageSize: Int = StandardPageSize,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endpoint = EndPoint.raceList
        let parameters = parametersForRaces(with: userId, filtering: filtering, latitude: latitude, longitude: longitude)
        repositoryAdapter.getObjects(endpoint, parameters: parameters, type: Race.self, completion)
    }

    public func getRaces(forChapter chapterId: ObjectId,
                         currentPage: Int = 0, pageSize: Int = StandardPageSize,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endpoint = EndPoint.raceList
        let parameters = [ParameterKey.chapterId: chapterId]

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Race.self) { (races, error) in
            completion(races, error)
        }
    }

    public func view(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>) {

        let endpoint = "\(EndPoint.raceView)?\(ParameterKey.id)=\(raceId)"
        repositoryAdapter.getObject(endpoint, type: Race.self, completion)
    }

    public func viewSimple(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>) {

        let endpoint = "\(EndPoint.raceViewSimple)?\(ParameterKey.id)=\(raceId)"
        repositoryAdapter.getObject(endpoint, type: Race.self, completion)
    }

    public func join(race raceId: ObjectId, aircraftId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceJoin)?\(ParameterKey.id)=\(raceId)"
        let parameters = [ParameterKey.aircraftId: aircraftId]

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func resign(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {
        
        let endpoint = "\(EndPoint.raceResign)?\(ParameterKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func open(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceOpen)?\(ParameterKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func close(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceClose)?\(ParameterKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func checkIn(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<RaceEntry>) {

        let endpoint = "\(EndPoint.raceCheckIn)?\(ParameterKey.id)=\(raceId)"
        repositoryAdapter.getObject(endpoint, type: RaceEntry.self, completion)
    }

    public func checkOut(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<RaceEntry>) {

        let endpoint = "\(EndPoint.raceCheckOut)?\(ParameterKey.id)=\(raceId)"
        repositoryAdapter.getObject(endpoint, type: RaceEntry.self, completion)
    }
}

fileprivate extension RaceApi {

    func parametersForRaces(with userId: ObjectId,
                            filtering: RaceListFiltering,
                            latitude: String? = nil, longitude: String? = nil) -> Parameters {
        
        var parameters: Parameters = [:]

        if filtering == .nearby {
            let settings = APIServices.shared.settings
            let lengthUnit = settings.lengthUnit
            var radiusString = settings.searchRadius

            if lengthUnit == .kilometers {
                radiusString = APIUnitSystem.convert(radiusString, to: .miles)
            }

            var nearbyDict = [ParameterKey.radius: radiusString]
            if let lat = latitude { nearbyDict[ParameterKey.latitude] = lat }
            if let long = longitude { nearbyDict[ParameterKey.longitude] = long }
            parameters[ParameterKey.nearBy] = nearbyDict
        } else {
            parameters[ParameterKey.joined] = [ParameterKey.pilotId : userId]
            if filtering == .upcoming {
                 parameters[ParameterKey.upcoming] = [ParameterKey.limit: 20]
            } else if filtering == .past {
                parameters[ParameterKey.past] = [ParameterKey.limit: 20]
            }
        }

        return parameters
    }
}
