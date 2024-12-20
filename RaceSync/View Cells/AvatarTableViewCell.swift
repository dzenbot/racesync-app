//
//  AvatarTableViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class AvatarTableViewCell: UITableViewCell {

    // MARK: - Public Variables

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                accessoryView = spinnerView
                spinnerView.startAnimating()
            } else {
                accessoryView = nil
                accessoryType = .disclosureIndicator
            }
        }
    }

    lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        label.textColor = Color.gray300
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

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
        label.textColor = Color.gray300
        return label
    }()

    // MARK: - Private Variables

    fileprivate lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()

    fileprivate lazy var spinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        return view
    }()

    fileprivate var rankLabelWidthConstraint: Constraint?
    fileprivate var leftSpacingConstraint: Constraint?

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

    open func setupLayout() {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Color.gray50
        self.selectedBackgroundView = selectedBackgroundView

        accessoryType = .disclosureIndicator

        contentView.addSubview(rankLabel)
        rankLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.centerY.equalToSuperview()
            rankLabelWidthConstraint = $0.width.equalTo(Constants.imageHeight/2).constraint
            rankLabelWidthConstraint?.activate()
        }

        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.height.width.equalTo(Constants.imageHeight)
            $0.centerY.equalToSuperview()
            leftSpacingConstraint = $0.leading.equalTo(rankLabel.snp.trailing).offset(Constants.padding/2).constraint
            leftSpacingConstraint?.activate()
        }

        contentView.addSubview(textStackView)
        textStackView.snp.makeConstraints {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(Constants.padding*3)
            $0.centerY.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        leftSpacingConstraint?.update(offset: rankLabel.isHidden ? 0 : Constants.padding/2)
        rankLabelWidthConstraint?.update(offset: rankLabel.isHidden ? 0 : Constants.imageHeight/2)
    }

}
