//
//  AlertUtil.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-05.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

public typealias AlertCompletionBlock = (UIAlertAction) -> Void

class AlertUtil {

    static func presentAlertMessage(_ message: String?, title: String? = nil, buttonTitle: String? = nil, delay: TimeInterval = 0, completion: AlertCompletionBlock? = nil) {

        let alert = UIAlertController(title: title ?? "Something Went Wrong", message: message ?? "Please try again.", preferredStyle: .alert)
        alert.view.tintColor = Color.blue
        
        alert.addAction(UIAlertAction(title: buttonTitle ?? "Ok", style: .default, handler: completion))
        if buttonTitle != nil {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            guard let topMostVC = UIViewController.topMostViewController() else { return }
            topMostVC.present(alert, animated: true, completion: nil)
        })
    }
}
