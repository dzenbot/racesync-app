//
//  RotatingIconView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-07.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class RotatingIconView: UIView {

    // MARK: - Public Variables

    var rotationSpeed: CFTimeInterval = 1.75 {
        didSet {
            stopAnimating()
            startAnimating()
        }
    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupLayout()
        startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Animation

    var isAnimating: Bool = false

    func startAnimating() {
        guard !isAnimating else { return }

        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = rotationSpeed
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        imageView.layer.add(rotation, forKey: "rotationAnimation")

        isAnimating = true
    }

    func stopAnimating() {
        guard isAnimating else { return }

        imageView.layer.removeAllAnimations()

        isAnimating = false
    }
}
