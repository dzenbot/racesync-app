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
typealias UploadMultipartFormResultCompletion = (Alamofire.SessionManager.MultipartFormDataEncodingResult) -> Void

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

        params[ParameterKey.apiKey] = APIServices.shared.credential.apiKey

        if let sessionId = APISessionManager.getSessionId() {
            params[ParameterKey.sessionId] = sessionId
        }

        formHeaders(headers, authProtected: authProtected) { [unowned self] (headers) in
            let request = self.sessionManager.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
                .validate(statusCode: 200...302)
                .validate(contentType: ["application/json"])
            completion?(request)
        }
    }

    func httpUpload(_ data: Data, url: String, method: HTTPMethod = .post, headers: [String: String]? = nil, completion: UploadRequestCompletion?) {

        var httpHeaders: [String : String] = headers ?? [:]
        httpHeaders[ParameterKey.apiKey] = APIServices.shared.credential.apiKey

        if let sessionId = APISessionManager.getSessionId() {
            httpHeaders[ParameterKey.sessionId] = sessionId
        }

        formHeaders(httpHeaders, authProtected: true) { [unowned self] (headers) in
            let request = self.sessionManager.upload(data, to: url, method: method, headers: headers)
                .validate(statusCode: 200...302)
                .validate(contentType: ["application/json"])
            completion?(request)
        }
    }

    func httpUpload(_ fileURL: URL, url: String, method: HTTPMethod = .put, headers: [String: String]? = nil, completion: UploadRequestCompletion?) {
        formHeaders(headers, authProtected: true) { [unowned self] (headers) in
            let request = self.sessionManager.upload(fileURL, to: url, method: method, headers: headers)
                .validate(statusCode: 200...302)
                .validate(contentType: ["application/json"])
            completion?(request)
        }
    }

    func httpMultipartUpload(_ data: Data,
                             name: String,
                             url: String,
                             method: HTTPMethod = .post,
                             headers: [String: String]? = nil,
                             completion: UploadMultipartFormResultCompletion?) {

        var httpHeaders: [String : String] = headers ?? [:]
        httpHeaders[ParameterKey.apiKey] = APIServices.shared.credential.apiKey
        httpHeaders[ParameterKey.sessionId] = APISessionManager.getSessionId()

        let fileName = "Image-\(UUID().uuidString).jpg"

        upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: name, fileName: fileName, mimeType: "image/jpeg")
        }, to: url, method: method, headers: httpHeaders)
        { (result) in
            completion?(result)
        }
    }

    func httpCancelRequests(with endpoint: String) {
        self.sessionManager.session.getTasksWithCompletionHandler { (sessionDataTask, _, _) in
            sessionDataTask.forEach {
                if let request = $0.currentRequest, let url = request.url {
                    if url.absoluteString.contains(endpoint) {
                    }
                }
            }
        }
    }

    func httpCancelAllRequests() {
        self.sessionManager.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
}

fileprivate extension NetworkAdapter {

    func urlFrom(endpoint: String) -> String {
        return "\(serverUri)\(endpoint)"
    }

    func formHeaders(_ headers: [String: String]?, authProtected: Bool, completion: @escaping ([String: String]) -> Void) {
        var headers = SessionManager.defaultHTTPHeaders
        headers[ParameterKey.contentType] = "application/json"

        // The server requires basic authorization header
        // when interacting with test.multigp.com
        // It is a base64 encoded string for "mgp:TestMe!"
        if APIServices.shared.settings.isDev {
            headers[ParameterKey.authorization] = authorizationHeader() //"Basic bWdwOlRlc3RNZSE="
        }

        completion(headers)
    }

    func authorizationHeader() -> String {
        guard let data = "mgp:TestMe!".data(using: .utf8) else { return "" }
        let credential = data.base64EncodedString(options: [])
        return "Basic \(credential)"
    }
}
