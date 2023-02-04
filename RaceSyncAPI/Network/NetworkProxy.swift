//
//  NetworkProxy.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2021-10-25.
//  Copyright © 2021 MultiGP Inc. All rights reserved.
//

import Foundation

var requestCount = 0

// TODO: Implement so the request count tracking can be done.
// Maybe use the proxy for other things too? like override environment endpoints on the fly?
public class NetworkProxy: URLProtocol {

    public override class func canInit(with request: URLRequest) -> Bool {
        print("Request #\(requestCount+1): URL = \(String(describing: request.url?.absoluteString))")
        return false
    }


    public override func startLoading() {
        //
    }

    public override func stopLoading() {
        //
    }
}
