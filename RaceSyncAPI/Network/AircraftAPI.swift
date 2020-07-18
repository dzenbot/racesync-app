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
    func createAircraft(with specs: AircraftSpecs, _ completion: @escaping ObjectCompletionBlock<Aircraft>)

    /**
    */
    func update(aircraft aircraftId: ObjectId, with specs: AircraftSpecs, _ completion: @escaping StatusCompletionBlock)

    /**
    */
    func retire(aircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock)

    /**
    */
    func uploadImage(_ image: UIImage, imageType: ImageType, forAircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock)
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

    public func createAircraft(with specs: AircraftSpecs, _ completion: @escaping ObjectCompletionBlock<Aircraft>) {

        let endpoint = EndPoint.aircraftCreate
        let parameters = specs.toParameters()

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Aircraft.self, completion)
    }

    public func update(aircraft aircraftId: ObjectId, with specs: AircraftSpecs, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.aircraftUpdate)?\(ParameterKey.id)=\(aircraftId)"
        let parameters = specs.toParameters()

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func retire(aircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.aircraftRetire)?\(ParameterKey.id)=\(aircraftId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func uploadImage(_ image: UIImage, imageType: ImageType, forAircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock) {

    let endpoint = imageType == .main ? EndPoint.aircraftUploadMainImage : EndPoint.aircraftUploadBackground
    let url = MGPWebConstant.apiBase.rawValue + "\(endpoint)?\(ParameterKey.id)=\(aircraftId)"
    guard let data = image.pngData() else { return }

    repositoryAdapter.networkAdapter.httpUpload(data, url: url, method: .post, headers: nil) { (request) in

        Clog.log("Starting request \(String(describing: request.request?.url)))")
            request.responseJSON(completionHandler: { (response) in
                Clog.log("Ended request with code \(String(describing: response.response?.statusCode))")

                if let code = response.response?.statusCode, code == 401 {
                    Clog.log("Detected 401. Should log out User!")
                }

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let errors = ErrorUtil.errors(fromJSON: json) {
                        completion(false, errors.first)
                    } else {
                        completion(true, nil)
                    }
                case .failure:
                    completion(false, response.error as NSError?)
                }
            })
        }
    }
}

