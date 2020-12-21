//
//  TrackElementHeaderView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class TrackElementHeaderView: UICollectionReusableView {

    // MARK: - Private Variables

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Color.gray200
        label.textAlignment = .left
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Color.blue
        label.textAlignment = .right
        return label
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupLayout() {
        backgroundColor = Color.white

        addSubview(leftLabel)
        leftLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding*1.25)
            $0.top.equalToSuperview().offset(Constants.padding/2)
        }

        addSubview(rightLabel)
        rightLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.padding*1.25)
            $0.top.equalToSuperview().offset(Constants.padding/2)
        }
    }
}
