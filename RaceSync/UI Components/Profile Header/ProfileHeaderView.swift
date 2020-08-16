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
import TOCropViewController

protocol ProfileHeaderViewDelegate {
    func shouldUploadImage(_ image: UIImage, imageType: ImageType, for objectId: ObjectId)
}

class ProfileHeaderView: UIView {

    // MARK: - Public Variables

    var topLayoutInset: CGFloat = 0

    var viewModel: ProfileViewModel? {
        didSet {
            setupLayout()
            updateContent()
        }
    }

    var isEditable: Bool = false {
        didSet {
            cameraButton.isHidden = !isEditable
            avatarView.isUserInteractionEnabled = isEditable
            backgroundView.isUserInteractionEnabled = isEditable
        }
    }

    var delegate: ProfileHeaderViewDelegate?

    lazy var locationButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.red
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setImage(UIImage(named: "icn_pin_small"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: -Constants.padding)
        button.shouldHighlight = true
        return button
    }()

    lazy var cameraButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.setImage(UIImage(named: "icn_button_camera"), for: .normal)
        button.tintColor = Color.white
        button.isHidden = true
        button.hitTestEdgeInsets = UIEdgeInsets(proportionally: -20)
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        button.layer.shadowColor = Color.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 2.5
        return button
    }()

    lazy var avatarView: ProfileAvatarView = {
        let view = ProfileAvatarView()
        view.isUserInteractionEnabled = isEditable
        view.addTarget(self, action: #selector(didPressAvatarView), for: .touchUpInside)
        return view
    }()

    lazy var backgroundView: ProfileBackgroundView = {
        let view = ProfileBackgroundView()
        view.isUserInteractionEnabled = isEditable
        view.addTarget(self, action: #selector(didPressBackgroundView), for: .touchUpInside)
        return view
    }()

    var backgroundViewSize = CGSize(width: UIScreen.main.bounds.width, height: Constants.headerHeight)

    func hideLeftBadgeButton(_ hide: Bool) {
        leftBadgeButton.isHidden = hide
    }

    func hideRightBadgeButton(_ hide: Bool) {
        rightBadgeButton.isHidden = hide
    }

    // MARK: - Private Variables

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
        button.layer.shadowColor = Color.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 1.0
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
        stackView.spacing = Constants.padding*1.5
        return stackView
    }()

    fileprivate var hasLaidOut: Bool = false

    fileprivate var imagePicker: ImagePickerController?

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

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    fileprivate func setupLayout() {
        guard !hasLaidOut else { return }

        backgroundColor = Color.white

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(snp.top).offset(-topLayoutInset)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(Constants.headerHeight)
        }

        addSubview(avatarView)
        avatarView.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(-Constants.avatarHeight*6/7) // 85%
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.avatarHeight)
        }

        addSubview(cameraButton)
        cameraButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        addSubview(leftBadgeButton)
        leftBadgeButton.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(Constants.padding/2)
            $0.leading.equalToSuperview().offset(Constants.padding)
        }

        addSubview(rightBadgeButton)
        rightBadgeButton.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(Constants.padding/2)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        addSubview(topBadgeButton)
        topBadgeButton.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(-Constants.padding*2)
            $0.leading.equalToSuperview().offset(Constants.padding/2)
        }

        addSubview(headerLabelStackView)
        headerLabelStackView.snp.makeConstraints {
            $0.top.equalTo(avatarView.snp.bottom).offset(Constants.padding)
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
            backgroundView.imageView.image = placeholder
        }

        func handleAvatarImage(_ image: UIImage?) {
            guard image == nil else { return }
            avatarView.imageView.image = viewModel.type.placeholder
        }

        let headerImageSize = CGSize(width: 0, height: Constants.headerHeight)
        let headerPlaceholder = UIImage.image(withColor: Color.gray100, imageSize: CGSize(width: UIScreen.main.bounds.width, height: Constants.headerHeight))
        if let headerImageUrl = ImageUtil.getSizedUrl(viewModel.backgroundUrl, size: headerImageSize) {
            backgroundView.imageView.setImage(with: headerImageUrl, placeholderImage: headerPlaceholder) { (image) in
                handleBackgroundImage(image)
            }
        } else {
            handleBackgroundImage(nil)
        }

        let avatarImageSize = CGSize(width: Constants.avatarHeight, height: Constants.avatarHeight)
        let avatarPlaceholder = UIImage.image(withColor: Color.gray100, imageSize: avatarImageSize)
        if let avatarImageUrl = ImageUtil.getSizedUrl(viewModel.pictureUrl, size: avatarImageSize) {
            avatarView.imageView.setImage(with: avatarImageUrl, placeholderImage: avatarPlaceholder) { (image) in
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

    // MARK: - Actions

    @objc fileprivate func didPressAvatarView(_ sender: Any) {
        guard isEditable else { return }
        presentUploadSheet(.main)
    }

    @objc fileprivate func didPressBackgroundView(_ sender: Any) {
        guard isEditable else { return }
        presentUploadSheet(.background)
    }

    @objc fileprivate func didTapCameraButton() {
        guard isEditable else { return }
        presentUploadSheet(.background)
    }
}

// MARK: - Image Upload

fileprivate extension ProfileHeaderView {

    func presentUploadSheet(_ imageType: ImageType) {
        guard let topMostVC = UIViewController.topMostViewController() else { return }
        guard let viewModel = viewModel else { return }

        let alert = UIAlertController(title: "Upload \(imageType.title) image for your \(viewModel.type.rawValue)", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = Color.blue

        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            self?.presentImagePicker(.camera, imageType: imageType)
        })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] (action) in
            self?.presentImagePicker(.photoLibrary, imageType: imageType)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Do something?
        })

        topMostVC.present(alert, animated: true)
    }

    func presentImagePicker(_ source: UIImagePickerController.SourceType = .photoLibrary, imageType: ImageType) {
        guard let objectId = viewModel?.id else { return }

        let picker = ImagePickerController()

        var croppingStyle: TOCropViewCroppingStyle = .circular

        if imageType == .background {
            croppingStyle = .default
            picker.customAspectRatio = CGSize(width: 1100, height: 360)
        }

        picker.presentImagePicker(source, croppingStyle: croppingStyle) { [weak self] (image, error) in
            guard let image = image else { return }
            self?.delegate?.shouldUploadImage(image, imageType: imageType, for: objectId)
        }

        imagePicker = picker
    }
}
