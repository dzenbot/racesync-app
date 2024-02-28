//
//  DimmableView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-08-03.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

// Used for view highlight on touch down. Similar effect than when pressing a UIButton.
class DimmableView: UIControl {

    var didTouch: Bool = false
    var dimmableView: UIView?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = dimmableView else { return }

        guard !didTouch else { return }
        if let touch = touches.first {
            let _ = touch.location(in: self)

            didTouch = true
            dim(view, dim: true)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = dimmableView else { return }

        if let touch = touches.first {
            let location = touch.location(in: self)

            let alpha = view.alpha

            if (bounds.contains(location)) {
                didTouch = true
                if alpha == 1 { dim(view, dim: true) }
            } else {
                didTouch = false
                if alpha < 1 { dim(view, dim: false) }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = dimmableView else { return }

        if let touch = touches.first {
            let _ = touch.location(in: self)

            dim(view, dim:false)

            if didTouch {
                didTouch = false
                sendActions(for: .touchUpInside)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = dimmableView else { return }

        if let touch = touches.first {
            let _ = touch.location(in: self)

            didTouch = false
            dim(view, dim: false, animated: false)
        }
    }

    fileprivate func dim(_ view: UIView, dim: Bool, animated: Bool = true) {
        let duration: TimeInterval = animated ? 0.2 : 0
        let alpha: CGFloat = dim ? 0.55 : 1.0

        UIView.animate(withDuration: duration) {
            view.alpha = alpha
        }
    }
}
