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

public enum RaceListFilter: String {
    case upcoming = "upcoming"
    case past = "past"
    case nearby = "nearby"
    case series = "qualifier"
    case all = "all"
}

public protocol RaceApiInterface {

    /**
     Gets a filtered set of races related to the authenticated User.

     - parameter filter: The list filterying type, such as upcoming, past, nearby, qualifier and all
     - parameter latitude: The coordinate longitude (Optional)
     - parameter longitude: The coordinate longitude (Optional)
     - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
     */
    func getMyRaces(filter: RaceListFilter, latitude: String?, longitude: String?, completion: @escaping ObjectCompletionBlock<[Race]>)

    /**
    Gets a filtered set of races related to a specific User.

    - parameter userId: The User id (Optional)
    - parameter filter: The list filterying type, such as upcoming, past, nearby, qualifier and all
    - parameter latitude: The coordinate longitude (Optional)
    - parameter longitude: The coordinate longitude (Optional)
    - parameter currentPage: The current page cursor position. Default is 0
    - parameter pageSize: The amount of objects to be returned by page. Default is 25.
    - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
    */
    func getRaces(forUser userId: ObjectId, filter: RaceListFilter, latitude: String?, longitude: String?, currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Race]>)

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
    func forceJoin(race raceId: ObjectId, pilotId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
    */
    func forceResign(race raceId: ObjectId, pilotId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
     */
    func open(race raceId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
     */
    func close(race raceId: ObjectId, completion: @escaping StatusCompletionBlock)

    /**
    */
    func checkIn(race raceId: ObjectId, pilotId: ObjectId?, completion: @escaping ObjectCompletionBlock<RaceEntry>)

    /**
    */
    func checkOut(race raceId: ObjectId, pilotId: ObjectId?, completion: @escaping ObjectCompletionBlock<RaceEntry>)

    /**
     */
    func create(race chapterId: ObjectId, raceSpecs: RaceSpecs, _ completion: @escaping ObjectCompletionBlock<Race>)

    /**
    */
    func cancelAll()
}

public class RaceApi: RaceApiInterface {

    public init() {}

    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyRaces(filter: RaceListFilter,
                           latitude: String? = nil,
                           longitude: String? = nil,
                           completion: @escaping ObjectCompletionBlock<[Race]>) {
        guard let user = APIServices.shared.myUser else { return }
        let lat = latitude ?? user.latitude
        let long = longitude ?? user.longitude
        getRaces(forUser: user.id, filter: filter, latitude: lat, longitude: long, completion: completion)
    }

    public func getRaces(forUser userId: ObjectId = "",
                         filter: RaceListFilter,
                         latitude: String? = nil, longitude: String? = nil,
                         currentPage: Int = 0, pageSize: Int = StandardPageSize,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endpoint = EndPoint.raceList
        let parameters = parametersForRaces(with: userId, filter: filter, latitude: latitude, longitude: longitude)
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

    public func forceJoin(race raceId: ObjectId, pilotId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceForceJoin)?\(ParameterKey.id)=\(raceId)"
        let parameters = [ParameterKey.pilotId: pilotId]

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func forceResign(race raceId: ObjectId, pilotId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceResign)?\(ParameterKey.id)=\(raceId)"
        let parameters = [ParameterKey.pilotId: pilotId]

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func open(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceOpen)?\(ParameterKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func close(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceClose)?\(ParameterKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func checkIn(race raceId: ObjectId, pilotId: ObjectId? = nil, completion: @escaping ObjectCompletionBlock<RaceEntry>) {

        let endpoint = "\(EndPoint.raceCheckIn)?\(ParameterKey.id)=\(raceId)"

        var parameters = Parameters()
        parameters[ParameterKey.pilotId] = pilotId

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: RaceEntry.self, completion)
    }

    public func checkOut(race raceId: ObjectId, pilotId: ObjectId? = nil, completion: @escaping ObjectCompletionBlock<RaceEntry>) {

        let endpoint = "\(EndPoint.raceCheckOut)?\(ParameterKey.id)=\(raceId)"

        var parameters = Parameters()
        parameters[ParameterKey.pilotId] = pilotId

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: RaceEntry.self, completion)
    }

    public func create(race chapterId: ObjectId, raceSpecs: RaceSpecs, _ completion: @escaping ObjectCompletionBlock<Race>) {

        let endpoint = "\(EndPoint.raceCreate)?\(ParameterKey.chapterId)=\(chapterId)"
        let parameters = raceSpecs.toParameters()

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Race.self, completion)
    }

    public func cancelAll() {
        repositoryAdapter.networkAdapter.httpCancelRequests(with: "race/")
    }
}

fileprivate extension RaceApi {

    func parametersForRaces(with userId: ObjectId = "",
                            filter: RaceListFilter,
                            latitude: String? = nil, longitude: String? = nil) -> Parameters {
        
        var parameters: Parameters = [:]

        if filter == .nearby {
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
            parameters[ParameterKey.upcoming] = [ParameterKey.limit: StandardPageSize]
        } else if filter == .gq {
            parameters[ParameterKey.qualifier] = true
            parameters[ParameterKey.upcoming] = [ParameterKey.limit: StandardPageSize]
        } else {
            parameters[ParameterKey.joined] = [ParameterKey.pilotId : userId]
            if filter == .upcoming {
                 parameters[ParameterKey.upcoming] = [ParameterKey.limit: StandardPageSize]
            } else if filter == .past {
                parameters[ParameterKey.past] = [ParameterKey.limit: StandardPageSize]
            }
        }

        return parameters
    }
}
