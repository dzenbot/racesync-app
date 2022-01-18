//
//  ImageUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-17.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

public class ImageUtil {

    static public func getSizedUrl(_ url: String?, size: CGSize, scale: CGFloat = UIScreen.main.scale) -> String? {
        if let URL = getSizedURL(url, size: size, scale: scale), URL.host != nil {
            return URL.absoluteString
        }
        return nil
    }

    static public func getSizedURL(_ url: String?, size: CGSize, scale: CGFloat = UIScreen.main.scale) -> URL? {
        guard let url = url else { return nil }

        if isImgixEnabled {
            let newUrl = url.replacingOccurrences(of: MGPWebConstant.s3Url.rawValue, with: MGPWebConstant.imgixUrl.rawValue)
            var components = URLComponents(string: newUrl)

            var queryItems = [URLQueryItem]()
            if (size.width > 0) { queryItems.append(URLQueryItem(name: ParameterKey.width, value: String("\(Int(size.width))"))) }
            if (size.height > 0) { queryItems.append(URLQueryItem(name: ParameterKey.height, value: String("\(Int(size.height))"))) }
            queryItems.append(URLQueryItem(name: ParameterKey.scale, value: String("\(Int(scale))")))
            queryItems.append(URLQueryItem(name: ParameterKey.format, value: "jpeg"))
            components?.queryItems = queryItems

            return components?.url
        } else {
            return URL(string: url)
        }
    }

    static let isImgixEnabled: Bool = false // The API is currently down https://multigp.imgix.net/
}

fileprivate extension ImageUtil {

    enum ParameterKey {
        static let width = "w"
        static let height = "h"
        static let scale = "dpr"
        static let format = "fm"
    }
}
