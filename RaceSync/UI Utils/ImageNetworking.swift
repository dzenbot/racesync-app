//
//  ImageNetworking.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-28.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

public typealias ImageBlock = (_ image: UIImage?) -> Void

class ImageNetworking {

    static func cachedImage(for urlString: String) -> UIImage? {
        let imageDownloader = UIImageView.af_sharedImageDownloader
        guard let url = URL(string: urlString) else { return nil }

        let image = imageDownloader.imageCache?.image(for: URLRequest(url: url), withIdentifier: urlString.hashValue.string)
        return image
    }
}

extension UIImageView {

    func setImage(with urlString: String?, placeholderImage: UIImage?, size: CGSize = .zero, completion: ImageBlock? = nil) {
        image = placeholderImage

        let filter = AspectScaledImageFilter(size: size)

        if let urlString = urlString, let url = URL(string: urlString), url.host != nil {
            af_setImage(withURL: url, placeholderImage: placeholderImage, filter: filter,
            completion: { response in
                switch response.result {
                case .success(let image):
                    completion?(image)
                case .failure:
                    completion?(nil)
                }
            })
        } else {
            image = placeholderImage
        }
    }
}

extension UIButton {
    func setImage(with urlString: String?, placeholderImage: UIImage?, forState state: UIControl.State = .normal, size: CGSize = .zero, completion: ImageBlock? = nil) {

        let filter = AspectScaledImageFilter(size: size)

        if let urlString = urlString, let url = URL(string: urlString) {
            af_setImage(for: state, url: url, placeholderImage: placeholderImage, filter: filter,
            completion: { response in
                switch response.result {
                case .success(let image):
                    completion?(image)
                case .failure:
                    completion?(nil)
                }
            })
        } else {
            setImage(placeholderImage, for: state)
        }
    }
}

struct AspectScaledImageFilter: ImageFilter, Sizable {

    public let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public var filter: (Image) -> Image {
        return { image in
            if self.size != .zero {
                return image.af_imageAspectScaled(toFit: self.size).withRenderingMode(.alwaysOriginal)
            } else {
                return image.withRenderingMode(.alwaysOriginal)
            }
        }
    }
}
