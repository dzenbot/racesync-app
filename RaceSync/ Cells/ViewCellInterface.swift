//
//  ViewCellInterface.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-10.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

protocol ViewCellInterface {
    static var identifier: String { get }
    static var height: CGFloat { get }
}

extension ViewCellInterface {

    static var identifier: String {
        return String(describing: type(of: self))
    }

    static var height: CGFloat {
        return UniversalConstants.cellHeight
    }
}
