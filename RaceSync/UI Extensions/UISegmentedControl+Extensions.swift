//
//  UISegmentedControl+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

extension UISegmentedControl {

    func setItems(_ items: [String]) {
        guard !items.isEmpty else { return }

        for i in 0..<items.count {
            insertSegment(withTitle: items[i], at: i, animated: false)
        }
    }

    func setSelectedSegment(_ index: NSInteger) {
        guard selectedSegmentIndex != index else { return }

        selectedSegmentIndex = index
        sendActions(for: .valueChanged)
    }
}
