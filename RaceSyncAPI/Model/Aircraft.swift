//
//  Aircraft.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Aircraft: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var scannableId: String = ""
    public var name: String = ""
    public var urlName: String = ""
    public var description: String = ""
    public var mainImageUrl: String = ""
    public var backgroundImageUrl: String?

    public var retired: Bool = true
    public var type: Int = 0
    public var size: Int = 0
    public var wingSize: Int = 0
    public var videoTransmitter: Int = 0
    public var videoTransmitterPower: Int = 0
    public var videoTransmitterChannels: Int = 0
    public var videoReceiverChannels: Int = 0
    public var antenna: Int = 0
    public var battery: Int = 0
    public var propellerSize: Int = 0
    public var entryCount: Int = 0

    // MARK: - Initialization

    fileprivate static let requiredProperties = ["id"]

    public required convenience init?(map: Map) {
        for requiredProperty in Aircraft.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {

    }

}
