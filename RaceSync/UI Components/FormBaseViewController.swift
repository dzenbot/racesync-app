//
//  FormViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-23.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

typealias ItemSelectionBlock = (_ item: String) -> Void

enum FormType {
    case textfield, textPicker, datePicker, `switch`, textEditor, undefined
}

class FormBaseViewController: UIViewController {
    weak var delegate: FormBaseViewControllerDelegate?
    open var isLoading: Bool = false
    open var formType: FormType = .undefined

    var didSelectItem: ItemSelectionBlock?
    var didDismiss: VoidCompletionBlock?
}

@objc protocol FormBaseViewControllerDelegate {
    func formViewController(_ viewController: FormBaseViewController, didSelectItem item: String)
    func formViewControllerDidDismiss(_ viewController: FormBaseViewController)

    @objc optional func formViewController(_ viewController: FormBaseViewController, enableSelectionWithItem item: String) -> Bool
    @objc optional func formViewControllerRightBarButtonTitle(_ viewController: FormBaseViewController) -> String
    @objc optional func formViewControllerKeyboardReturnKeyType(_ viewController: FormBaseViewController) -> UIReturnKeyType
}

