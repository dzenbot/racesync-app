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
        return getSizedURL(url, size: size, scale: scale)?.absoluteString
    }

    static public func getSizedURL(_ url: String?, size: CGSize, scale: CGFloat = UIScreen.main.scale) -> URL? {
        guard let url = url else { return nil }

        let newUrl = url.replacingOccurrences(of: ImageUtil.s3Url, with: ImageUtil.imgixUrl)
        var components = URLComponents(string: newUrl)

        var queryItems = [URLQueryItem]()
        if (size.width > 0) { queryItems.append(URLQueryItem(name: ParameterKey.width, value: String("\(Int(size.width))"))) }
        if (size.height > 0) { queryItems.append(URLQueryItem(name: ParameterKey.height, value: String("\(Int(size.height))"))) }
        queryItems.append(URLQueryItem(name: ParameterKey.scale, value: String("\(Int(scale))")))
        queryItems.append(URLQueryItem(name: ParameterKey.format, value: "jpeg"))
        components?.queryItems = queryItems

        return components?.url
    }
}

fileprivate extension ImageUtil {

    static let s3Url = "https://s3.amazonaws.com/multigp-storage"
    static let imgixUrl = "https://multigp.imgix.net"

    enum ParameterKey {
        static let width = "w"
        static let height = "h"
        static let scale = "dpr"
        static let format = "fm"
    }
}
