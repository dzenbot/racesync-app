//
//  RSAPIKey.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-10-27.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public protocol APIEnvironment {
    var baseURL: String { get }
    var apiKey: String { get }
    var username: String { get }
    var password: String { get }
    var isDev: Bool { get }
}

public struct DevEnvironment : APIEnvironment {
    public let baseURL: String = "https://test.multigp.com/mgp/multigpwebservice/"
    public let apiKey: String = "3WlfklZkaSO7p8Y3qwxebeSEMllyLVyPST4cf4xqWmxmuwqU2Y9dc2SYnex9a5Y2Z3ff8MF48drCJRxLPHZ2KS186yihEgjDkyTslyxtLY6uQEgFlgI68JefiwwWNQA7"
    public let username: String = "ignacio.romeroz@gmail.com"
    public let password: String = "VosspcwXp2n3VZ9"
    public let isDev: Bool = true
}

public struct ProdEnvironment : APIEnvironment {
    public let baseURL: String = "https://www.multigp.com/mgp/multigpwebservice/"
    public let apiKey: String = "3WlfklZkaSO7p8Y3qwxebeSEMllyLVyPST4cf4xqWmxmuwqU2Y9dc2SYnex9a5Y2Z3ff8MF48drCJRxLPHZ2KS186yihEgjDkyTslyxtLY6uQEgFlgI68JefiwwWNQA7"
    public let username: String = "ignacio.romeroz@gmail.com"
    public let password: String = "VosspcwXp2n3VZ9"
    public let isDev: Bool = false
}

// "ignacio.romeroz+test@gmail.com"
// "g3EwxoU2oyFEsI%p"
