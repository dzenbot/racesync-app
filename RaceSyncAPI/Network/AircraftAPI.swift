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
    func uploadBackgroundImage(_ image: UIImage, forAircraft aircraftId: ObjectId, progressBlock: ProgressBlock?, _ completion: @escaping StatusCompletionBlock)
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

    public func uploadMainImage(_ image: UIImage, forAircraft aircraftId: ObjectId, progressBlock: ProgressBlock? = nil, _ completion: @escaping StatusCompletionBlock) {
        let url = MGPWebConstant.apiBase.rawValue + "\(EndPoint.aircraftUploadMainImage)?\(ParameterKey.id)=\(aircraftId)"
        uploadImage(image, name: ParameterKey.mainImageInput, endpoint: url, progressBlock: progressBlock, completion)
    }

    public func uploadBackgroundImage(_ image: UIImage, forAircraft aircraftId: ObjectId, progressBlock: ProgressBlock? = nil, _ completion: @escaping StatusCompletionBlock) {
        let url = MGPWebConstant.apiBase.rawValue + "\(EndPoint.aircraftUploadBackground)?\(ParameterKey.id)=\(aircraftId)"
        uploadImage(image, name: ParameterKey.backgroundImageInput, endpoint: url, progressBlock: progressBlock, completion)
    }

    public func uploadImage(_ image: UIImage, name: String, endpoint: String, progressBlock: ProgressBlock?, _ completion: @escaping StatusCompletionBlock) {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }

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

                    let json = JSON(response.result.value as Any)
                    if let errors = ErrorUtil.errors(fromJSON: json) {
                        completion(false, errors.first)
                    } else {
                        completion(true, nil)
                    }
                }

            case .failure(let encodingError):
                print(encodingError)
            }
        }

        // Non-multipart request implementation
//        guard let fileURL = Bundle.main.url(forResource: "drone2", withExtension: "jpg") else { return }
//
//        repositoryAdapter.networkAdapter.httpUpload(fileURL, url: endpoint) { (request) in
//        repositoryAdapter.networkAdapter.httpUpload(data, url: endpoint, method: .put) { request in
//            Clog.log("Starting request \(String(describing: request.request?.url)))")
//
//            request.uploadProgress(closure: { (progress) in
//                let fractionCompleted: Float = Float(progress.fractionCompleted)
//                print("completion \(fractionCompleted)")
//                progressBlock?(fractionCompleted)
//            })
//            .responseData(completionHandler: { (response) in
//                Clog.log("Ended request with code \(String(describing: response.response?.statusCode))")
//
//                if let code = response.response?.statusCode, code == 401 {
//                    Clog.log("Detected 401. Should log out User!")
//                }
//
//                switch response.result {
//                case .success:
//                    completion(true, nil)
//                case .failure:
//                    completion(false, ErrorUtil.parseError(response))
//                }
//            })
//        }
    }
}

