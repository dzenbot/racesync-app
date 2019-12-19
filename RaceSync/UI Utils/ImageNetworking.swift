//
//  UIImage+Networking.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-28.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

public typealias ImageBlock = (_ image: UIImage?) -> Void

extension UIImageView {

    func setImage(with urlString: String?, placeholderImage: UIImage?, renderingMode: UIImage.RenderingMode = .alwaysOriginal, completion: ImageBlock? = nil) {
        image = placeholderImage

        if let urlString = urlString, let url = URL(string: urlString) {
            af_setImage(withURL: url, placeholderImage: placeholderImage, filter: DynamicImageFilter("OriginalFilterImage") { image in
                return image.withRenderingMode(renderingMode)
            },
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
    func setImage(with urlString: String?, placeholderImage: UIImage?, forState state: UIControl.State = .normal, renderingMode: UIImage.RenderingMode = .alwaysOriginal, completion: ImageBlock? = nil) {
        if let urlString = urlString, let url = URL(string: urlString) {
            af_setImage(for: state, url: url, placeholderImage: placeholderImage, filter: DynamicImageFilter("OriginalFilterImage") { image in
                return image.withRenderingMode(renderingMode)
            },
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
