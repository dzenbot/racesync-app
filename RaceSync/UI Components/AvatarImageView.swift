//
//  AvatarImageView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class AvatarImageView: UIView {

    // MARK: - Public Variables

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.white
        imageView.layer.cornerRadius = height/2
        imageView.layer.masksToBounds = true
        return imageView
    }()

    // MARK: - Private Variables

    fileprivate let height: CGFloat
    fileprivate let showShadow: Bool

    // MARK: - Initializatiom

    init(withHeight height: CGFloat = 30, showShadow: Bool = true) {
        self.height = height
        self.showShadow = showShadow
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupLayout() {

        backgroundColor = Color.clear

        if showShadow {
            layer.shadowColor = Color.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1.0)
            layer.shadowOpacity = 0.25
            layer.shadowRadius = 1.25
        }

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: height, height: height)
    }
}

