//
//  Appearance.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-16.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import AlamofireImage

class Appearance {
    static func configureUIAppearance() {
        configureViewAppearance()
        configureNavigationBarAppearance()
        configureTabBarAppearance()
        configureActivityIndicatorAppearance()
    }
}

fileprivate extension Appearance {

    static func configureViewAppearance() {
        let windowAppearance = UIWindow.appearance()
        windowAppearance.tintColor = Color.blue

        if let mainWindow = UIApplication.shared.delegate?.window as? UIWindow {
            mainWindow.backgroundColor = Color.white

            if #available(iOS 13.0, *) {
                mainWindow.overrideUserInterfaceStyle = .light
            }
        }
    }

    static func configureNavigationBarAppearance() {
        let foregroundColor = Color.blue
        let backgroundColor = Color.navigationBarColor
        let backIndicatorImage = UIImage(named: "icn_arrow_backward")
        let backgroundImage = UIImage.image(withColor: backgroundColor, imageSize: CGSize(width: 44, height: 44))

        // set the color and font for the title
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = backgroundColor
        navigationBarAppearance.tintColor = foregroundColor
        navigationBarAppearance.barStyle = .default
        navigationBarAppearance.setBackgroundImage(backgroundImage, for: .default)
        navigationBarAppearance.isOpaque = false
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.backIndicatorImage = backIndicatorImage?.withRenderingMode(.alwaysTemplate)
        navigationBarAppearance.backIndicatorTransitionMaskImage = backIndicatorImage
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
                                                       NSAttributedString.Key.foregroundColor: Color.black]
    }

    static func configureTabBarAppearance() {
        //
    }

    static func configureTabBarItemAppearance() {
        //
    }

    static func configureActivityIndicatorAppearance() {
        let appearance = UIActivityIndicatorView.appearance()
        appearance.color = Color.gray300
        appearance.hidesWhenStopped = true
    }

    static func configureImageCache() {
        // Disabling the image cache for now, to by pass an issue where images being later fetched from disk
        // are not correctly scaled down to the device scale. This is causing them to blow out on the layout.
        // TODO: Investigate and find a fix, or else, switch away from the AlamoFireImage lib
        UIImageView.af_sharedImageDownloader = ImageDownloader(imageCache: nil)
    }
}
