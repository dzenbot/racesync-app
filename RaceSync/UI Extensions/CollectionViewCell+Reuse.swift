//
//  CollectionViewCell+Reuse.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-18.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

enum CollectionViewSectionType {
    case footer, header

    var string: String {
        switch self {
        case .footer:   return UICollectionView.elementKindSectionFooter
        case .header:   return UICollectionView.elementKindSectionHeader
        }
    }
}

extension UICollectionReusableView: Reusable { }

extension UICollectionView {

    func register<T: UICollectionReusableView>(cellType: T.Type) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    func register<T: UICollectionReusableView>(cellType: T.Type, forSupplementaryViewOf kind: CollectionViewSectionType) {
        register(cellType.self, forSupplementaryViewOfKind: kind.string, withReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: CollectionViewSectionType, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableSupplementaryView(ofKind: elementKind.string, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}
