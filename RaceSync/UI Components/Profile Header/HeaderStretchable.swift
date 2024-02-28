//
//  HeaderStretchable.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-16.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

protocol HeaderStretchable {

    var targetHeaderView: StretchableView { get }
    var targetHeaderViewSize: CGSize { get }
    var topLayoutInset: CGFloat { get }

    var anchoredViews: [UIView]? { get }

    func stretchHeaderView(with contentOffset: CGPoint)
}

extension HeaderStretchable where Self: UIViewController {

    func stretchHeaderView(with contentOffset: CGPoint) {
        let layoutInset = topLayoutInset

        // skipping from doing calculations if not needed
        guard contentOffset.y < -layoutInset else { return }

        let scrollRatio = contentOffset.y + layoutInset
        let movingUp: Bool = scrollRatio < 0

        let imageViewSize = targetHeaderViewSize
        let scrollXOffset = movingUp ? scrollRatio : 0
        let scrollYOffset = movingUp ? contentOffset.y : -layoutInset
        let newWidth = movingUp ? imageViewSize.width - scrollRatio*2 : imageViewSize.width
        let newHeight = movingUp ? imageViewSize.height - scrollRatio : imageViewSize.height

        let newFrame = CGRect(x: scrollXOffset, y: scrollYOffset, width: newWidth , height: newHeight)
        targetHeaderView.changeLayerFrame(newFrame)

        if let anchoredViews = anchoredViews {
            for view in anchoredViews {
                view.layer.frame.origin.y = layoutInset + UniversalConstants.padding + scrollYOffset
            }
        }
    }
}

protocol StretchableView {
    func changeLayerFrame(_ frame: CGRect)
}
