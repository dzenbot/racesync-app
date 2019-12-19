//
//  ActionSheetUtil.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-05.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class ActionSheetUtil {

    static func presentDestructiveActionSheet(withTitle title: String, message: String?, destructiveTitle: String?, completion: AlertCompletionBlock?) {
        guard let topMostVC = UIViewController.topMostViewController() else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: destructiveTitle ?? "Ok", style: .destructive, handler: completion))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        topMostVC.present(alert, animated: true, completion: nil)
    }

}
