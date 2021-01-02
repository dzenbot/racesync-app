//
//  ChapterTableViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-21.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class ChapterTableViewCell: UITableViewCell {

    // MARK: - Public Variables

    lazy var avatarImageView: AvatarImageView = {
        return AvatarImageView(withHeight: Constants.imageHeight)
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = Color.black
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = Color.gray500
        return label
    }()

    // MARK: - Private Variables

    fileprivate lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let imageHeight: CGFloat = UniversalConstants.cellAvatarHeight
    }

    // MARK: - Initializatiom

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        self.accessoryType = .disclosureIndicator

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Color.gray50
        self.selectedBackgroundView = selectedBackgroundView

        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.height.width.equalTo(Constants.imageHeight)
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.centerY.equalToSuperview()
        }

        contentView.addSubview(labelStackView)
        labelStackView.snp.makeConstraints {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(Constants.padding)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
