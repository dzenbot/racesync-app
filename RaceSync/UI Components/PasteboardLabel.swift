//
//  PasteboardLabel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class PasteboardLabel: UILabel, TextCopiable {

    // MARK: - Initializatiom

    override init(frame: CGRect) {
        super.init(frame: frame)
        isCopiable()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Pasteboard Management

    override public var canBecomeFirstResponder: Bool {
        get { return true }
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
}
