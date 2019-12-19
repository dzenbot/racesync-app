//
//  PasteboardButton.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-26.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class PasteboardButton: UIButton, TextCopiable {

    var shouldHighlight: Bool = false

    // MARK: - Initializatiom

    override init(frame: CGRect) {
        super.init(frame: frame)
        isCopiable()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var isHighlighted: Bool {
        get { return shouldHighlight ? super.isHighlighted : false }
        set { if shouldHighlight { super.isHighlighted = newValue } }
    }

    // MARK: - Pasteboard Management

    override public var canBecomeFirstResponder: Bool {
        get { return true }
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = titleLabel?.text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }

    override func sendActions(for controlEvents: UIControl.Event) {
        if !shouldHideCopyMenu() {
            super.sendActions(for: controlEvents)
        }
    }

    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if !shouldHideCopyMenu() {
            super.sendAction(action, to: target, for: event)
        }
    }
}
