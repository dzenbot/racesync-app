//
//  ActionButton.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

/**
 Long button taking the whole width of the screen, typically used for login screens and important actions
 at the bottom of a screen.
 */
class ActionButton: CustomButton {

    // MARK: - Public Variables

    var bouncesOnPress: Bool = false
    var showsShadow: Bool = false

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

    var isLoading: Bool = false {
        didSet {
            spinnerView.isHidden = !isLoading
            isUserInteractionEnabled = !isLoading
            animateSpinner(isLoading)

            // Since iOS7, setting titleLabel.hidden doesn't work anymore
            if isLoading {
                titleLabel?.removeFromSuperview()
            } else if let label = titleLabel {
                addSubview(label)
            }
        }
    }

    lazy var spinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)

        addSubview(view)
        view.snp.makeConstraints { (make) -> Void in
            make.centerX.centerY.equalToSuperview()
        }

        return view
    }()

    // MARK: - Animation

    fileprivate var isAnimating: Bool = false

    fileprivate func animate(press: Bool) {
        if press {
            let scale: CGFloat = 0.95
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }

    fileprivate func animateSpinner(_ animate: Bool) {
        if animate { spinnerView.startAnimating() } else { spinnerView.stopAnimating() }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        if showsShadow {
            layer.masksToBounds = false
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowColor = Color.black.cgColor
            layer.shadowRadius = 4.0
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
            layer.shadowOpacity = 0.1
        } else {
            layer.shadowPath = nil
            layer.shadowOpacity = 0
        }
    }

    // MARK: - Touch Events

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let begin = super.beginTracking(touch, with: event)
        guard !isLoading, isEnabled, bouncesOnPress else { return begin }
        animate(press: true)
        return begin
    }

    override func cancelTracking(with event: UIEvent?) {
        guard !isLoading, isEnabled, bouncesOnPress else { return }
        super.cancelTracking(with: event)
        animate(press: false)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        guard touch != nil, !isLoading, isEnabled, bouncesOnPress else { return }
        animate(press: false)
    }
}
