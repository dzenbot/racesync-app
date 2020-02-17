//
//  AircraftAPI.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-08.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

// MARK: - Interface
public protocol AircrafApiInterface {

    /**
     */
    func getMyAircrafts(forRaceSpecs specs: AircraftRaceSpecs?, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>)

    /**
     */
    func getAircrafts(forUser userId: String, forRaceSpecs specs: AircraftRaceSpecs?, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>)

    /**
    */
    func createAircraft(forAircraftSpecs specs: AircraftSpecs, _ completion: @escaping ObjectCompletionBlock<Aircraft>)

    /**
    */
    func delete(aircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock)
}

public class AircraftAPI: AircrafApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyAircrafts(forRaceSpecs specs: AircraftRaceSpecs? = nil, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>) {
        guard let myUser = APIServices.shared.myUser else { return }
        getAircrafts(forUser: myUser.id, forRaceSpecs: specs, completion)
    }

    public func getAircrafts(forUser userId: String, forRaceSpecs specs: AircraftRaceSpecs? = nil, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>) {

        let endpoint = EndPoint.aircraftList
        var parameters: Parameters = [ParameterKey.pilotId: userId, ParameterKey.retired: false]

        if let specs = specs {
            parameters += specs.toParameters()
        }

        repositoryAdapter.getObjects(endpoint, parameters: parameters, type: Aircraft.self, completion)
    }

    public func createAircraft(forAircraftSpecs specs: AircraftSpecs, _ completion: @escaping ObjectCompletionBlock<Aircraft>) {

        let endpoint = EndPoint.aircraftCreate
        let parameters = specs.toParameters()

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Aircraft.self, completion)
    }

    public func delete(aircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.aircraftDelete)?\(ParameterKey.id)=\(aircraftId)"

        repositoryAdapter.networkAdapter.httpRequest(endpoint,  method: .post) { (request) in
            print("Starting request \(String(describing: request.request?.url))")
            request.responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json[ParameterKey.status].bool ?? false, nil)
                case .failure:
                    completion(false, response.error as NSError?)
                }
            }
        }
    }
}
