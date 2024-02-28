//
//  CustomButton.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    // MARK: - Public Variables

    var hitTestEdgeInsets: UIEdgeInsets = .zero

    // MARK: - Private Variables

    // MARK: - Overrides

    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        var hitTest: Bool = false

        if hitTestEdgeInsets == .zero {
            hitTest = super.point(inside: point, with: event)
        } else {
            let hitFrame = bounds.inset(by: hitTestEdgeInsets)
            hitTest = hitFrame.contains(point)
        }

        return hitTest
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        longPressTimer = Timer.scheduledTimer(timeInterval: longPressDuration, target: self, selector: #selector(longPressTimerFired), userInfo: nil, repeats: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        invalidateLongPress()

        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        invalidateLongPress()

        super.touchesCancelled(touches, with: event)
    }

    // MARK: - Long Press

    private var longPressTimer: Timer?
    private let longPressDuration: TimeInterval = 0.5

    @objc private func longPressTimerFired() {
        super.sendActions(for: .touchLong)
        invalidateLongPress()
    }

    private func invalidateLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
}

public extension UIControl.Event {

    static var touchLong: UIControl.Event {
        get { return UIControl.Event(rawValue: 1 << 15) } // 32768
    }
}

