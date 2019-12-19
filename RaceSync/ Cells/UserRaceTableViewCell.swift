//
//  UserRaceTableViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class UserRaceTableViewCell: UITableViewCell {

    static var identifier: String = "UserRaceTableViewCell"

    // MARK: - Public Variables

    static var height: CGFloat {
        return Constants.cellHeight
    }

    lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView(withHeight: Constants.imageHeight)
        view.imageView.image = UIImage(named: "placeholder_medium")
        return view
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Color.gray200
        return label
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = Color.black
        return label
    }()

    lazy var joinButton: JoinButton = {
        let button = JoinButton(type: .system)
        button.isCompact = true
        button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        button.imageEdgeInsets = .zero
        button.contentEdgeInsets = .zero
        return button
    }()

    lazy var memberBadgeView: MemberBadgeView = {
        let view = MemberBadgeView(type: .system)
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Private Variables

    fileprivate lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.dateLabel, self.titleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let minButtonSize: CGFloat = 72
        static let imageHeight: CGFloat = 50
        static let cellHeight: CGFloat = 100
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

    func setupLayout() {

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Color.gray50
        self.selectedBackgroundView = selectedBackgroundView

        accessoryType = .disclosureIndicator

        let containerView = UIView()

        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.centerY.equalToSuperview()
        }

        containerView.addSubview(labelStackView)
        labelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.padding)
            $0.leading.trailing.equalToSuperview()
        }

        containerView.addSubview(memberBadgeView)
        memberBadgeView.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().offset(-Constants.padding)
            $0.leading.equalToSuperview()
            $0.height.equalTo(25)
        }

        containerView.addSubview(joinButton)
        joinButton.snp.makeConstraints {
            $0.top.equalTo(memberBadgeView.snp.top)
            $0.bottom.equalTo(memberBadgeView.snp.bottom)
            $0.leading.equalTo(memberBadgeView.snp.trailing).offset(7)
            $0.width.height.equalTo(25)
        }

        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding/2)
            $0.centerY.equalToSuperview()
        }
    }
}
