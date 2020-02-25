//
//  FormViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-23.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {
    var delegate: FormViewControllerDelegate?
    open var isLoading: Bool = false
    open var formType: FormType = .undefined
}

enum FormType {
    case picker, textfield, undefined
}

@objc protocol FormViewControllerDelegate {
    func formViewController(_ viewController: FormViewController, didSelectItem item: String)
    func formViewControllerDidDismiss(_ viewController: FormViewController)

    @objc optional func formViewController(_ viewController: FormViewController, enableSelectionWithItem item: String) -> Bool
    @objc optional func formViewControllerRightBarButtonTitle(_ viewController: FormViewController) -> String
    @objc optional func formViewControllerKeyboardReturnKeyType(_ viewController: FormViewController) -> UIReturnKeyType
}
