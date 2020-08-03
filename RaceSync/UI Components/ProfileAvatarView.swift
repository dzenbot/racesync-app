//
//  ProfileAvatarView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-08-03.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class ProfileAvatarView: UIControl {

    // MARK: - Public Variables

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.white
        imageView.layer.cornerRadius = height/2
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let height: CGFloat = 170

    // MARK: - Private Variables

    fileprivate lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.black
        view.layer.cornerRadius = height/2
        view.layer.masksToBounds = true
        return view
    }()

    fileprivate lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = height/2
        view.layer.masksToBounds = true
        return view
    }()

    fileprivate var didTouch: Bool = false

    // MARK: - Initializatiom

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        backgroundColor = Color.clear

        layer.shadowColor = Color.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 2.5

        addSubview(backdropView)
        backdropView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didTouch else { return }
        if let touch = touches.first {
            let _ = touch.location(in: self)

            didTouch = true
            dimImageView(true)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)

            let alpha = imageView.alpha

            if (bounds.contains(location)) {
                didTouch = true
                if alpha == 1 { dimImageView(true) }
            } else {
                didTouch = false
                if alpha < 1 { dimImageView(false) }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let _ = touch.location(in: self)

            dimImageView(false)

            if didTouch {
                didTouch = false
                sendActions(for: .touchUpInside)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let _ = touch.location(in: self)

            didTouch = false
            dimImageView(false)
        }
    }

    fileprivate func dimImageView(_ dim: Bool) {
        let alpha: CGFloat = dim ? 0.3 : 1.0
        let alpha2: CGFloat = dim ? 0.8 : 1.0

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.imageView.alpha = alpha
            self?.backgroundView.alpha = alpha2
        }
    }
}
