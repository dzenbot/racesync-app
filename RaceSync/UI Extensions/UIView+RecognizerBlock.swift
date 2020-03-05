//
//  UIView+RecognizerBlock.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-26.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

public typealias GestureRecognizerCompletionBlock = (UIGestureRecognizer) -> Void

extension UIView {

    public func addTapGestureRecognizer(completion: GestureRecognizerCompletionBlock?) {
        self.isUserInteractionEnabled = true

        self.tapGestureRecognizerBlock = completion
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        self.addGestureRecognizer(gestureRecognizer)
    }

    public func addLongPressGestureRecognizer(completion: GestureRecognizerCompletionBlock?) {
        self.isUserInteractionEnabled = true

        self.longPressGestureRecognizerBlock = completion
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer))
        self.addGestureRecognizer(gestureRecognizer)
    }
}

fileprivate extension UIView {

    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if let block = self.tapGestureRecognizerBlock {
            block(sender)
        }
    }

    @objc func handleLongPressGestureRecognizer(_ sender: UILongPressGestureRecognizer) {
        if let block = self.longPressGestureRecognizerBlock {
            block(sender)
        }
    }

    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    struct AssociatedObjectKeys {
        static var tapGestureRecognizerBlock = "TapGestureRecognizer_block_key"
        static var longPressGestureRecognizerBlock = "LongPressGestureRecognizer_block_key"
    }

    var tapGestureRecognizerBlock: GestureRecognizerCompletionBlock? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizerBlock, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizerBlock) as? GestureRecognizerCompletionBlock
        }
    }

    var longPressGestureRecognizerBlock: GestureRecognizerCompletionBlock? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.longPressGestureRecognizerBlock, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.longPressGestureRecognizerBlock) as? GestureRecognizerCompletionBlock
        }
    }
}
