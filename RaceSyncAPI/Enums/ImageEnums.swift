//
//  ImageEnums.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-06-25.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public enum ImageType {
    case main
    case background

    public var title: String {
        switch self {
        case .main:         return "avatar"
        case .background:   return "background"
        }
    }

    public var key: String {
        switch self {
        case .main:         return "mainImageInput"
        case .background:   return "backgroundImageInput"
        }
    }

    public var endpoint: String {
        switch self {
        case .main:         return EndPoint.aircraftUploadMainImage
        case .background:   return EndPoint.aircraftUploadBackground
        }
    }
}
