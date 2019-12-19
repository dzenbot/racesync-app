//
//  UserTableViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class UserTableViewCell: UITableViewCell {

    static var identifier: String = "UserTableViewCell"

    // MARK: - Public Variables

    static var height: CGFloat {
        return Constants.cellHeight
    }

    lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView(withHeight: Constants.imageHeight)
        view.imageView.image = UIImage(named: "placeholder_medium")
        return view
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

    lazy var channelBadge: ChannelBadge = {
        let channelBadge = ChannelBadge()
        channelBadge.isHidden = true
        return channelBadge
    }()

    // MARK: - Private Variables

       fileprivate lazy var labelStackView: UIStackView = {
           let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
           stackView.axis = .vertical
           stackView.distribution = .fillEqually
           stackView.alignment = .leading
           stackView.spacing = 2
           return stackView
       }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let imageHeight: CGFloat = 50
        static let cellHeight: CGFloat = 90
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

        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.height.width.equalTo(Constants.imageHeight)
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.centerY.equalToSuperview()
        }

        contentView.addSubview(channelBadge)
        channelBadge.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.padding/2)
            $0.centerY.equalToSuperview()
        }

        contentView.addSubview(labelStackView)
        labelStackView.snp.makeConstraints {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(Constants.padding)
            $0.trailing.equalTo(channelBadge.snp.leading).offset(-Constants.padding/2)
            $0.centerY.equalToSuperview()
        }
    }

}
