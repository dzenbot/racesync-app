//
//  Appearance.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-16.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import AlamofireImage
import Presentr

class Appearance {
    static func configureUIAppearance() {
        configureViewAppearance()
        configureNavigationBarAppearance()
        configureTabBarAppearance()
        configureToolBarAppearance()
        configureActivityIndicatorAppearance()
    }

    static func defaultPresenter() -> Presentr {
        let presenter = Presentr(presentationType: .bottomHalf)
        presenter.blurBackground = false
        presenter.backgroundOpacity = 0.2
        presenter.transitionType = .coverVertical
        presenter.dismissTransitionType = .coverVertical
        presenter.dismissAnimated = true
        presenter.dismissOnSwipe = true
        presenter.backgroundTap = .dismiss
        presenter.outsideContextTap = .passthrough
        presenter.roundCorners = true
        presenter.cornerRadius = 10
        return presenter
    }
}

fileprivate extension Appearance {

    static func configureViewAppearance() {
        let windowAppearance = UIWindow.appearance()
        windowAppearance.tintColor = Color.blue

        if let mainWindow = UIApplication.shared.delegate?.window {
            mainWindow?.backgroundColor = Color.white

            if #available(iOS 13.0, *) {
                mainWindow?.overrideUserInterfaceStyle = .light
            }
        }
    }

    static func configureNavigationBarAppearance() {
        let foregroundColor = Color.blue
        let backgroundColor = Color.navigationBarColor
        let backIndicatorImage = UIImage(named: "icn_navbar_back")
        let backgroundImage = UIImage.image(withColor: backgroundColor, imageSize: CGSize(width: 44, height: 44))


        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            navigationBarAppearance.backgroundColor = backgroundColor
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }

        // set the color and font for the title
        let barAppearance = UINavigationBar.appearance()
        barAppearance.barTintColor = backgroundColor
        barAppearance.tintColor = foregroundColor
        barAppearance.barStyle = .default
        barAppearance.setBackgroundImage(backgroundImage, for: .default)
        barAppearance.isOpaque = false
        barAppearance.isTranslucent = true
        barAppearance.backIndicatorImage = backIndicatorImage?.withRenderingMode(.alwaysTemplate)
        barAppearance.backIndicatorTransitionMaskImage = backIndicatorImage
        barAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
                                                       NSAttributedString.Key.foregroundColor: Color.black]
    }

    static func configureTabBarAppearance() {
        let foregroundColor = Color.red
        let backgroundColor = Color.navigationBarColor
        let unselectedItemTintColor = Color.gray300
        let backgroundImage = UIImage.image(withColor: backgroundColor, imageSize: CGSize(width: 44, height: 44))

        // set the color and font for the title
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = backgroundColor
        tabBarAppearance.tintColor = foregroundColor
        tabBarAppearance.unselectedItemTintColor = unselectedItemTintColor
        tabBarAppearance.barStyle = .default
        tabBarAppearance.backgroundImage = backgroundImage
        tabBarAppearance.isOpaque = false
        tabBarAppearance.isTranslucent = true
    }

    static func configureToolBarAppearance() {
        let foregroundColor = Color.blue
        let backgroundColor = Color.navigationBarColor

        // set the color and font for the title
        let toolBarAppearance = UIToolbar.appearance()
        toolBarAppearance.barTintColor = backgroundColor
        toolBarAppearance.tintColor = foregroundColor
        toolBarAppearance.barStyle = .default
        toolBarAppearance.isOpaque = false
        toolBarAppearance.isTranslucent = true
    }

    static func configureTabBarItemAppearance() {
        //
    }

    static func configureActivityIndicatorAppearance() {
        let appearance = UIActivityIndicatorView.appearance()
        appearance.color = Color.gray300
        appearance.hidesWhenStopped = true
    }
}
