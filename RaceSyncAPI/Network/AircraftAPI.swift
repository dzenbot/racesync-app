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
    func getMyAircrafts(_ completion: @escaping ObjectCompletionBlock<[Aircraft]>)

    /**
     */
    func getAircrafts(forUser userId: String, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>)

    /**
    */
    func createAircraft(withSpecs specs: String, _ completion: @escaping ObjectCompletionBlock<ObjectId>)
}

public class AircraftAPI: AircrafApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyAircrafts(_ completion: @escaping ObjectCompletionBlock<[Aircraft]>) {
        guard let myUser = APIServices.shared.myUser else { return }
        getAircrafts(forUser: myUser.id, completion)
    }

    public func getAircrafts(forUser userId: String, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>) {

        let endpoint = EndPoint.aircraftList
        let parameters: Parameters = [ParameterKey.pilotId: userId, ParameterKey.retired: false]

        repositoryAdapter.getObjects(endpoint, parameters: parameters, type: Aircraft.self, completion)
    }

    public func createAircraft(withSpecs specs: String, _ completion: @escaping ObjectCompletionBlock<ObjectId>) {

        let endpoint = EndPoint.aircraftCreate
        let parameters = Parameters()

        repositoryAdapter.networkAdapter.httpRequest(endpoint, method: .post, parameters: parameters, nestParameters: false) { (request) in
            print("Starting request \(String(describing: request.request?.url)) with parameters \(String(describing: parameters))")
            request.responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    let _ = JSON(value)
                    completion(nil, nil)
                case .failure:
                    completion(nil, ErrorUtil.parseError(response))
                }
            })
        }
    }
}
