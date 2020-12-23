//
//  UIScrollView+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-18.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//
//  Inspired from https://timoliver.blog/2012/01/14/zooming-to-a-point-in-uiscrollview/

import UIKit

extension UIScrollView {

    func toggleZoom(with gestureRecognizer: UIGestureRecognizer, animated: Bool = true) {
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let touchPoint = gestureRecognizer.location(in: superview)
            zoom(to: touchPoint, with: maximumZoomScale, animated: animated)
        }
    }

    func zoom(to point: CGPoint, with scale: CGFloat, animated: Bool = true) {
        // Normalize current content size back to content scale of 1.0f
        let newContentSize = CGSize(width: (contentSize.width / zoomScale),
                                    height: (contentSize.height / zoomScale))

        // Translate the zoom point to relative to the content rect
        let newPoint = CGPoint(x: (point.x / bounds.size.width) * newContentSize.width,
                               y: (point.y / bounds.size.height) * newContentSize.height)

        // Derive the size of the region to zoom to
        let zoomSize = CGSize(width: bounds.size.width / scale,
                              height: bounds.size.height / scale)

        // Offset the zoom rect so the actual zoom point is in the middle of the rectangle
        let zoomRect = CGRect(x: newPoint.x - zoomSize.width / 2.0,
                              y: newPoint.y - zoomSize.height / 2.0,
                              width: zoomSize.width,
                              height: zoomSize.height)

        zoom(to: zoomRect, animated: animated)
    }
}
