//
//  HeaderStretchable.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-16.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

protocol HeaderStretchable {

    var targetHeaderView: UIView { get }
    var targetHeaderViewSize: CGSize { get }
    var topLayoutInset: CGFloat { get }
    
    func stretchHeaderView(with contentOffset: CGPoint)
}

extension HeaderStretchable where Self: UIViewController {

    func stretchHeaderView(with contentOffset: CGPoint) {
        let layoutInset = topLayoutInset

        // skipping from doing calculations if not needed
        guard contentOffset.y < -layoutInset else { return }

        let scrollOffset = contentOffset.y
        let scrollRatio = contentOffset.y + layoutInset
        let imageViewSize = targetHeaderViewSize

        if scrollRatio < 0 {
            targetHeaderView.layer.frame = CGRect(x: scrollRatio, y: scrollOffset, width: imageViewSize.width - scrollRatio*2 , height: imageViewSize.height - scrollRatio);
        } else {
            targetHeaderView.layer.frame = CGRect(x: 0, y: -layoutInset, width: imageViewSize.width, height: imageViewSize.height);
        }
    }
}
