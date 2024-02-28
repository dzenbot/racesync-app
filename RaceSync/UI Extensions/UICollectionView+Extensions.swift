//
//  UICollectionView+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-17.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

extension UICollectionView {

    func deselectAllItems(_ animated: Bool = true) {
        guard let indexPaths = indexPathsForSelectedItems else { return }
        for item in indexPaths {
            deselectItem(at: item, animated: animated)
        }
    }
}
