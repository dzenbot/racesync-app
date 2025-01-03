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

        let status: Bool? = value[ParamKey.status] as? Bool
        let description: String? = value[ParamKey.statusDescription] as? String
        let httpStatus: Int = value[ParamKey.httpStatus] as? Int ?? 0

        if let errorsDict = value[ParamKey.errors] as? [String: Any] {
            if let errors = errorsDict.values.first as? [String] {
                let errorStr = errors.joined(separator: " ")
                return NSError(domain: "Error", code: httpStatus, userInfo: [NSLocalizedDescriptionKey : errorStr])
            }
        } else if let status = status, status == false, let description = description {
            return NSError(domain: "Error", code: httpStatus, userInfo: [NSLocalizedDescriptionKey : description])
        } else if let status = status, status == false {
            return undefinedError
        } else if let apiError = ApiError.from(JSON: value) {
            return formError(apiError)
        }

        return generalError
    }

    static func errors(fromJSONString string: String) -> [NSError]? {
        let json = JSON(string)
        return errors(fromJSON: json)
    }

    static func errors(fromJSON json: JSON) -> [NSError]? {

        var errors = [NSError]()

        for (_, value) in json[ParamKey.errors] {
            if let content = value.array?.first, let description = content.string {
                errors += [generateError(description, withCode: .malfunction)]
            }
        }

        // Looking for false status responses
        if let status = json[ParamKey.status].rawValue as? Bool, status == false,
           let description = json[ParamKey.statusDescription].rawValue as? String {
            errors += [generateError(description, withCode: .malfunction)]
        }

        // Looking for HTTP error exceptions
        if json.isEmpty, let jsonString = json.rawString(), jsonString.contains("Exception") {
            errors += [generateError(jsonString, withCode: .malfunction)]
        }

        return errors.count > 0 ? errors : nil
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

