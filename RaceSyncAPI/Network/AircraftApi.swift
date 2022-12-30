//
//  AircraftApi.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-08.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// MARK: - Interface
public protocol AircrafApiInterface {

    /**
     */
    func getMyAircraft(forRaceData data: AircraftRaceData?, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>)

    /**
     */
    func getAircraft(forUser userId: String, forRaceData data: AircraftRaceData?, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>)

    /**
    */
    func createAircraft(with data: AircraftData, _ completion: @escaping ObjectCompletionBlock<Aircraft>)

    /**
    */
    func update(aircraft aircraftId: ObjectId, with data: AircraftData, _ completion: @escaping StatusCompletionBlock)

    /**
    */
    func retire(aircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock)

    /**
    */
    func uploadImage(_ image: UIImage, imageType: ImageType, forAircraft aircraftId: ObjectId, progressBlock: ProgressBlock?, _ completion: @escaping ObjectCompletionBlock<String>)
}

public class AircraftApi: AircrafApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getMyAircraft(forRaceData data: AircraftRaceData? = nil, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>) {
        guard let myUser = APIServices.shared.myUser else { return }
        getAircraft(forUser: myUser.id, forRaceData: data, completion)
    }

    public func getAircraft(forUser userId: String, forRaceData data: AircraftRaceData? = nil, _ completion: @escaping ObjectCompletionBlock<[Aircraft]>) {

        let endpoint = EndPoint.aircraftList
        var parameters: Parameters = [ParamKey.pilotId: userId, ParamKey.retired: false]

        if let data = data {
            parameters += data.toParameters()
        }

        repositoryAdapter.getObjects(endpoint, parameters: parameters, type: Aircraft.self, completion)
    }

    public func createAircraft(with data: AircraftData, _ completion: @escaping ObjectCompletionBlock<Aircraft>) {

        let endpoint = EndPoint.aircraftCreate
        let parameters = data.toParameters()

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Aircraft.self, completion)
    }

    public func update(aircraft aircraftId: ObjectId, with data: AircraftData, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.aircraftUpdate)?\(ParamKey.id)=\(aircraftId)"
        let parameters = data.toParameters()

        repositoryAdapter.performAction(endpoint, parameters: parameters, completion: completion)
    }

    public func retire(aircraft aircraftId: ObjectId, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = "\(EndPoint.aircraftRetire)?\(ParamKey.id)=\(aircraftId)"

        repositoryAdapter.performAction(endpoint, completion: completion)
    }

    public func uploadImage(_ image: UIImage, imageType: ImageType, forAircraft aircraftId: ObjectId, progressBlock: ProgressBlock? = nil, _ completion: @escaping ObjectCompletionBlock<String>) {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }

        let url = MGPWebConstant.apiBase.rawValue + "\(imageType.endpoint)?\(ParamKey.id)=\(aircraftId)"
        uploadImage(data, name: imageType.key, endpoint: url, progressBlock: progressBlock, completion)
    }
}

fileprivate extension AircraftApi {

    func uploadImage(_ data: Data, name: String, endpoint: String, progressBlock: ProgressBlock?, _ completion: @escaping ObjectCompletionBlock<String>) {
        Clog.log("Starting request \(endpoint)")

        // Multipart
        repositoryAdapter.networkAdapter.httpMultipartUpload(data, name: name, url: endpoint) { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })

                upload.responseString { response in
                    Clog.log("Ended request with code \(String(describing: response.response?.statusCode))")

                    switch response.result {
                    case .success(let value):
                        let json = JSON.init(parseJSON: value)
                        if let errors = ErrorUtil.errors(fromJSONString: value) {
                            completion(nil, errors.first)
                        } else {
                            completion(json[ParamKey.url].rawValue as? String, nil)
                        }
                    case .failure:
                        completion(nil, response.error as NSError?)
                    }
                }

            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
}

