//
//  NetworkAdapter.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Alamofire

typealias DataRequestCompletion = (Alamofire.DataRequest) -> Void
typealias UploadRequestCompletion = (Alamofire.UploadRequest) -> Void

class NetworkAdapter {

    let sessionManager = Alamofire.SessionManager()
    let serverUri: String

    init(serverUri: String) {
        self.serverUri = serverUri
    }

    func httpRequest(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        nestParameters: Bool = true,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: [String : String] = [:],
        authProtected: Bool = true,
        completion: DataRequestCompletion?
        ) {
        let url = urlFrom(endpoint: endpoint)

        var params = Parameters()

        if nestParameters {
            params[ParameterKey.data] = parameters
        } else if let parameters = parameters {
            params = parameters
        }

        params[ParameterKey.apiKey] = APIServices.shared.environment.apiKey

        if let sessionId = APISessionManager.retrieveSessionId() {
            params[ParameterKey.sessionId] = sessionId
        }

        formHeaders(headers, authProtected: authProtected) { [unowned self] (headers) in
            let request = self.sessionManager.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
                .validate(statusCode: 200...302)
                .validate(contentType: ["application/json"])

            completion?(request)
        }
    }

    func httpUpload(_ data: Data, url: String, method:HTTPMethod, headers: [String:String]?, completion: UploadRequestCompletion?) {
        formHeaders(headers, authProtected: true) { [unowned self] (headers) in
            let request = self.sessionManager.upload(data, to: url, method: method, headers: headers)
                .validate(statusCode: 200...302)
                .validate(contentType: ["application/json"])

            completion?(request)
        }
    }

    func httpUpload(_ fileURL: URL, url: String, method:HTTPMethod, completion: UploadRequestCompletion?) {
        formHeaders(nil, authProtected: true) { [unowned self] (headers) in
            let request = self.sessionManager.upload(fileURL, to: url, method: method, headers: headers)
                .validate(statusCode: 200...302)
                .validate(contentType: ["application/json"])

            completion?(request)
        }
    }

    fileprivate func urlFrom(endpoint: String) -> String {
        return "\(serverUri)\(endpoint)"
    }

    fileprivate func formHeaders(_ headers: [String: String]?, authProtected: Bool, completion: @escaping ([String: String]) -> Void) {
        var headers: [String : String] = headers ?? [:]
        
        headers["Content-typ"] = "application/json"
        headers["platform"] = "ios"

        // The server requires basic authorization header
        // when interacting with test.multigp.com
        // It is a base64 encoded string for "mgp:TestMe!"
        if APIServices.shared.environment.isDev {
            headers["Authorization"] = authorizationHeader() //"Basic bWdwOlRlc3RNZSE="
        }

        completion(headers)
    }

    fileprivate func authorizationHeader() -> String {
        guard let data = "mgp:TestMe!".data(using: .utf8) else { return "" }
        let credential = data.base64EncodedString(options: [])
        return "Basic \(credential)"
    }

}
