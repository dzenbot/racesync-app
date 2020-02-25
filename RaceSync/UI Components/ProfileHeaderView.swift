//
//  ProfileHeaderView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-20.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class ProfileHeaderView: UIView {

    // MARK: - Public Variables

    var topLayoutInset: CGFloat = 0

    var viewModel: ProfileViewModel? {
        didSet {
            setupLayout()
            updateContent()
        }
    }

    lazy var locationButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.red
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setImage(UIImage(named: "icn_pin_small"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: -Constants.padding)
        button.shouldHighlight = true
        return button
    }()

    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var backgroundImageViewSize = CGSize(width: UIScreen.main.bounds.width, height: Constants.headerHeight)

    // MARK: - Private Variables

    fileprivate lazy var profileImageView: ProfileImageView = {
        return ProfileImageView()
    }()

    fileprivate lazy var mainTextLabel: PasteboardLabel = {
        let label = PasteboardLabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = Color.black
        label.numberOfLines = 2
        return label
    }()

    fileprivate lazy var topBadgeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Color.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.titleEdgeInsets = UIEdgeInsets(right: -Constants.padding/2)
        button.isUserInteractionEnabled = false
        return button
    }()

    fileprivate lazy var leftBadgeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Color.gray400
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.titleEdgeInsets = UIEdgeInsets(right: -Constants.padding/2)
        button.isUserInteractionEnabled = false
        return button
    }()

    fileprivate lazy var rightBadgeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Color.gray400
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding/2, bottom: 0, right: 0)
        button.isUserInteractionEnabled = false
        return button
    }()

    fileprivate lazy var headerLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainTextLabel, locationButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = Constants.padding
        return stackView
    }()

    fileprivate var hasLaidOut: Bool = false

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let headerHeight: CGFloat = 260
        static let avatarHeight: CGFloat = 170
    }

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        guard !hasLaidOut else { return }

        backgroundColor = Color.white

        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(snp.top).offset(-topLayoutInset)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(Constants.headerHeight)
        }

        addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(-Constants.avatarHeight*6/7) // 85%
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.avatarHeight)
        }

        addSubview(leftBadgeButton)
        leftBadgeButton.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(Constants.padding/2)
            $0.leading.equalToSuperview().offset(Constants.padding)
        }

        addSubview(rightBadgeButton)
        rightBadgeButton.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(Constants.padding/2)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        addSubview(topBadgeButton)
        topBadgeButton.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(-Constants.padding*2)
            $0.leading.equalToSuperview().offset(Constants.padding)
        }

        addSubview(headerLabelStackView)
        headerLabelStackView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(Constants.padding)
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.bottom.equalToSuperview()
        }

        hasLaidOut = true
    }

    // MARK: - Content

    fileprivate func updateContent() {
        guard let viewModel = viewModel else { return }

        func handleBackgroundImage(_ image: UIImage?) {
            guard image == nil else { return }
            let placeholder = UIImage(named: "placeholder_profile_background")
            backgroundImageView.image = placeholder
        }

        func handleAvatarImage(_ image: UIImage?) {
            guard image == nil else { return }

            var placeholder: UIImage?

            switch viewModel.type {
            case .user:         placeholder = UIImage(named: "placeholder_profile_avatar")
            case .chapter:      placeholder = UIImage(named: "placeholder_profile_avatar")
            case .aircraft:     placeholder = UIImage(named: "placeholder_profile_aircraft")
            }

            profileImageView.imageView.image = placeholder
        }

        let headerImageSize = CGSize(width: 0, height: Constants.headerHeight)
        let headerPlaceholder = UIImage.image(withColor: Color.gray100, imageSize: CGSize(width: UIScreen.main.bounds.width, height: Constants.headerHeight))
        if let headerImageUrl = ImageUtil.getSizedUrl(viewModel.backgroundUrl, size: headerImageSize) {
            backgroundImageView.setImage(with: headerImageUrl, placeholderImage: headerPlaceholder) { (image) in
                handleBackgroundImage(image)
            }
        } else {
            handleBackgroundImage(nil)
        }

        let avatarImageSize = CGSize(width: Constants.avatarHeight, height: Constants.avatarHeight)
        let avatarPlaceholder = UIImage.image(withColor: Color.gray100, imageSize: avatarImageSize)
        if let avatarImageUrl = ImageUtil.getSizedUrl(viewModel.pictureUrl, size: avatarImageSize) {
            profileImageView.imageView.setImage(with: avatarImageUrl, placeholderImage: avatarPlaceholder) { (image) in
                handleAvatarImage(image)
            }
        } else {
            handleAvatarImage(nil)
        }

        mainTextLabel.text = viewModel.displayName

        if !viewModel.locationName.isEmpty {
            locationButton.setTitle(viewModel.locationName, for: .normal)
        } else {
            locationButton.isHidden = true
        }

        if viewModel.topBadgeLabel != nil {
            topBadgeButton.setTitle(viewModel.topBadgeLabel, for: .normal)
            topBadgeButton.setImage(viewModel.topBadgeImage, for: .normal)
        }

        leftBadgeButton.setTitle(viewModel.leftBadgeLabel, for: .normal)
        leftBadgeButton.setImage(viewModel.leftBadgeImage, for: .normal)

        rightBadgeButton.setTitle(viewModel.rightBadgeLabel, for: .normal)
        rightBadgeButton.setImage(viewModel.rightBadgeImage, for: .normal)
    }
}

fileprivate class ProfileImageView: UIView {

    // MARK: - Variables

    let height: CGFloat = 170

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.white
        imageView.layer.cornerRadius = height/2
        imageView.layer.masksToBounds = true
        return imageView
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

    func setupLayout() {

        backgroundColor = Color.clear

        layer.shadowColor = Color.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 2.5

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}
