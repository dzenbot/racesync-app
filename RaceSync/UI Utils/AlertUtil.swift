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

    static func presentAlertMessage(_ message: String?, title: String?, buttonTitle: String? = nil, completion: AlertCompletionBlock? = nil) {
        guard let topMostVC = UIViewController.topMostViewController() else { return }

        let alert = UIAlertController(title: title ?? "Something Went Wrong", message: message ?? "Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle ?? "Ok", style: .default, handler: completion))
        if buttonTitle != nil {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }

        topMostVC.present(alert, animated: true, completion: nil)
    }
}
