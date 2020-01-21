//
//  ErrorUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum ErrorCode: Int {
    case undefined = 0
    case malfunction = 1
    case authorization = 2
    case notFound = 3
}

class ErrorUtil {

    static func parseError<T>(_ response: DataResponse<T>) -> NSError {
        guard let data = response.data, let value = JSON(data).dictionaryObject else {
            return generalError
        }

        let status: Bool? = value[ParameterKey.status] as? Bool
        let description: String? = value[ParameterKey.statusDescription] as? String
        let httpStatus: Int? = value[ParameterKey.httpStatus] as? Int

        if let status = status, status == false, let description = description, let httpStatus = httpStatus {
            return NSError(domain: "Error", code: httpStatus, userInfo: [NSLocalizedDescriptionKey : description])
        }
        else if let status = status, status == false {
            return undefinedError
        } else if let apiError = ApiError.from(JSON: value) {
            return formError(apiError)
        } else {
            return generalError
        }
    }

    static func formError(_ apiError: ApiError) -> NSError {
        return NSError(
            domain: "error",
            code: apiError.code,
            userInfo: [
                NSLocalizedDescriptionKey : apiError.message
            ]
        )
    }

    static let undefinedError: NSError = generateError("Undefined Error", withCode: .undefined)
    static let generalError: NSError = generateError("Something went wrong", withCode: .malfunction)
    static let authError: NSError = generateError("Your session has expired", withCode: .authorization)
    static let notFoundError: NSError = generateError("Resource not found", withCode: .notFound)

    static func generateError(_ localizedDescription: String, withCode code: ErrorCode) -> NSError {
        return NSError(domain: "Error", code: code.rawValue, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
    }
}

