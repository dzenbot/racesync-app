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
    case joined = "joined"
}

public protocol RaceApiInterface {

    /**
     Gets a filtered set of races related to the authenticated User.

     - parameter filters: The list of compounding filters to compose the race query
     - parameter latitude: The coordinate longitude (Optional)
     - parameter longitude: The coordinate longitude (Optional)
     - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
     */
    func getMyRaces(filters: [RaceListFilter], latitude: String?, longitude: String?, completion: @escaping ObjectCompletionBlock<[Race]>)

    /**
    Gets a filtered set of races related to a specific User.

    - parameter userId: The User id (Optional)
    - parameter filters: The list of compounding filters to compose the race query
    - parameter latitude: The coordinate longitude (Optional)
    - parameter longitude: The coordinate longitude (Optional)
    - parameter currentPage: The current page cursor position. Default is 0
    - parameter pageSize: The amount of objects to be returned by page. Default is 25.
    - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
    */
    func getRaces(forUser userId: ObjectId, filters: [RaceListFilter], latitude: String?, longitude: String?, currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Race]>)

    /**
    Gets the races belonging to a specific chapter.

    - parameter chapterId: The Chapter id.
    - parameter currentPage: The current page cursor position. Default is 0
    - parameter pageSize: The amount of objects to be returned by page. Default is 25.
    - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
    */
    func getRaces(forChapter chapterId: ObjectId, currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Race]>)

    /**
    Gets the races belonging to a specific season.

    - parameter seasonId: The Season id.
    - parameter currentPage: The current page cursor position. Default is 0
    - parameter pageSize: The amount of objects to be returned by page. Default is 25.
    - parameter completion: The closure to be called upon completion. Returns a transcient list of Race objects.
    */
    func getRaces(forSeason seasonId: ObjectId, currentPage: Int, pageSize: Int, completion: @escaping ObjectCompletionBlock<[Race]>)

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
    Creates a full Race object, using a data transfer object converted into parameters.

     - parameter data: The data transfer object
     - parameter completion: The closure to be called upon completion. Returns a transcient Race object.
    */
    func createRace(withData data: RaceData, completion: @escaping ObjectCompletionBlock<Race>)

    /**
     Cancels all the HTTP requests of race API endpoint
    */
    func cancelAll()
}

public class RaceApi: RaceApiInterface {

    public init() {}

    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyRaces(filters: [RaceListFilter],
                           latitude: String? = nil,
                           longitude: String? = nil,
                           completion: @escaping ObjectCompletionBlock<[Race]>) {
        guard let user = APIServices.shared.myUser else { return }
        let lat = latitude ?? user.latitude
        let long = longitude ?? user.longitude
        getRaces(forUser: user.id, filters: filters, latitude: lat, longitude: long, completion: completion)
    }

    public func getRaces(forUser userId: ObjectId = "",
                         filters: [RaceListFilter],
                         latitude: String? = nil, longitude: String? = nil,
                         currentPage: Int = 0, pageSize: Int = StandardPageSize,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endpoint = EndPoint.raceList
        let parameters = parametersForRaces(with: userId, filters: filters, latitude: latitude, longitude: longitude, pageSize: pageSize)
        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Race.self, completion)
    }

    public func getRaces(forChapter chapterId: ObjectId,
                         currentPage: Int = 0, pageSize: Int = StandardPageSize,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endpoint = EndPoint.raceList
        let parameters = [ParamKey.chapterId: chapterId]

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Race.self, completion)
    }

    public func getRaces(forSeason seasonId: ObjectId,
                         currentPage: Int = 0, pageSize: Int = StandardPageSize,
                         completion: @escaping ObjectCompletionBlock<[Race]>) {

        let endpoint = EndPoint.raceList
        let parameters = [ParamKey.seasonId: seasonId]

        repositoryAdapter.getObjects(endpoint, parameters: parameters, currentPage: currentPage, pageSize: pageSize, type: Race.self, completion)
    }

    public func view(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>) {

        let endpoint = "\(EndPoint.raceView)?\(ParamKey.id)=\(raceId)"
        repositoryAdapter.getObject(endpoint, type: Race.self, completion)
    }

    public func viewSimple(race raceId: ObjectId, completion: @escaping ObjectCompletionBlock<Race>) {

        let endpoint = "\(EndPoint.raceViewSimple)?\(ParamKey.id)=\(raceId)"
        repositoryAdapter.getObject(endpoint, type: Race.self, completion)
    }

    public func join(race raceId: ObjectId, aircraftId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceJoin)?\(ParamKey.id)=\(raceId)"
        let parameters = [ParamKey.aircraftId: aircraftId]

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func resign(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {
        
        let endpoint = "\(EndPoint.raceResign)?\(ParamKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func forceJoin(race raceId: ObjectId, pilotId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceForceJoin)?\(ParamKey.id)=\(raceId)"
        let parameters = [ParamKey.pilotId: pilotId]

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func forceResign(race raceId: ObjectId, pilotId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceResign)?\(ParamKey.id)=\(raceId)"
        let parameters = [ParamKey.pilotId: pilotId]

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func open(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceOpen)?\(ParamKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func close(race raceId: ObjectId, completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.raceClose)?\(ParamKey.id)=\(raceId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func checkIn(race raceId: ObjectId, pilotId: ObjectId? = nil, completion: @escaping ObjectCompletionBlock<RaceEntry>) {

        let endpoint = "\(EndPoint.raceCheckIn)?\(ParamKey.id)=\(raceId)"

        var parameters = Parameters()
        parameters[ParamKey.pilotId] = pilotId

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: RaceEntry.self, completion)
    }

    public func checkOut(race raceId: ObjectId, pilotId: ObjectId? = nil, completion: @escaping ObjectCompletionBlock<RaceEntry>) {

        let endpoint = "\(EndPoint.raceCheckOut)?\(ParamKey.id)=\(raceId)"

        var parameters = Parameters()
        parameters[ParamKey.pilotId] = pilotId

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: RaceEntry.self, completion)
    }

    public func createRace(withData data: RaceData, completion: @escaping ObjectCompletionBlock<Race>) {

        let endpoint = "\(EndPoint.raceCreate)?\(ParamKey.chapterId)=\(data.chapterId)"
        let parameters = data.toParameters()

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Race.self, completion)
    }

    public func cancelAll() {
        repositoryAdapter.networkAdapter.httpCancelRequests(with: "race/")
    }
}

fileprivate extension RaceApi {

    func parametersForRaces(with userId: ObjectId = "",
                            filters: [RaceListFilter],
                            latitude: String? = nil, longitude: String? = nil,
                            pageSize: Int = StandardPageSize) -> Parameters {

        var parameters: Parameters = [:]

        if filters.contains(.nearby) {
            let settings = APIServices.shared.settings
            let lengthUnit = settings.lengthUnit
            var radiusString = settings.searchRadius

            if lengthUnit == .kilometers {
                radiusString = APIUnitSystem.convert(radiusString, to: .miles)
            }

            var nearbyDict = [ParamKey.radius: radiusString]
            if let lat = latitude { nearbyDict[ParamKey.latitude] = lat }
            if let long = longitude { nearbyDict[ParamKey.longitude] = long }
            parameters[ParamKey.nearBy] = nearbyDict
        }

        if filters.contains(.joined) {
            parameters[ParamKey.joined] = [ParamKey.pilotId : userId]
        }

        if filters.contains(.series) {
            parameters[ParamKey.isQualifier] = true
        }

        if filters.contains(.upcoming) {
            parameters[ParamKey.upcoming] = [ParamKey.limit: pageSize]
        } else if filters.contains(.past) {
            parameters[ParamKey.past] = [ParamKey.limit: pageSize]
        }

        return parameters
    }
}
