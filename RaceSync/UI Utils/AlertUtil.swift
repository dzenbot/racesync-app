//
//  AlertUtil.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-05.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

public typealias AlertCompletionBlock = (UIAlertAction) -> Void
public typealias AlertTextfieldCompletionBlock = ([String: String]) -> Void

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
            topMostVC.present(alert, animated: true)
        })
    }

    static func presentAlertTextFields(_ textFields: [String], title: String? = nil, completion: AlertTextfieldCompletionBlock? = nil) {

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.view.tintColor = Color.blue

        for i in 0..<textFields.count {
            let placeholder = textFields[i]

            alert.addTextField { textField in
                textField.placeholder = placeholder
            }
        }

        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            guard let textFields = alert.textFields else { return }

            var result = [String: String]()

            for i in 0..<textFields.count {
                let txtfield = textFields[i]
                guard let key = txtfield.placeholder else { continue }
                result[key] = txtfield.text
            }

            completion?(result)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        guard let topMostVC = UIViewController.topMostViewController() else { return }
        topMostVC.present(alert, animated: true)
    }

}




