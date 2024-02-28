//
//  ImageUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-17.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

public class ImageUtil {

    static public func getImageUrl(for url: String?) -> String? {
        return url
    }

    static public func getImageURL(for url: String?) -> URL? {
        guard let url = url else { return nil }
        return URL(string: url)
    }
}
