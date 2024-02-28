//
//  TextBadge.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-14.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class TextBadge: UIView {

    // MARK: - Public Variables

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Color.white
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Private Variables

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let height: CGFloat = 26
    }

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        layer.cornerRadius = Constants.height/2
        layer.masksToBounds = true

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.height.equalTo(Constants.height)
            $0.centerY.equalToSuperview()
        }
    }
}
