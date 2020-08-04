//
//  ProfileAvatarView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-08-03.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class ProfileAvatarView: DimmableView {

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
        dimmableView = imageView
        
        layer.shadowColor = Color.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 2.5

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}
