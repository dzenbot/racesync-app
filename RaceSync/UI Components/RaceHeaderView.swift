//
//  RaceHeaderView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-13.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class RaceHeaderView: UIView {

    // MARK: - Public Variables

    var viewModel: RaceEntryViewModel? {
        didSet {
            setupLayout()
            updateContent()
        }
    }

    static var headerHeight: CGFloat {
        return Constants.height
    }

    lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView(withHeight: Constants.avatarHeight)
        view.imageView.image = UIImage(named: "placeholder_large")
        return view
    }()

    fileprivate lazy var backgroundLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 130, weight: .semibold)
        label.textColor = Color.gray50.withAlphaComponent(0.7)
        label.numberOfLines = 1
        return label
    }()

    fileprivate lazy var legendLabelsStackView: UIStackView = {
        let bandLabel = titleLabel(with: "Band")
        let channelLabel = titleLabel(with: "Channel")
        let polarizationLabel = titleLabel(with: "Polarization")

        let stackView = UIStackView(arrangedSubviews: [bandLabel, channelLabel, polarizationLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .lastBaseline
        stackView.spacing = 0
        return stackView
    }()

    func titleLabel(with text: String?) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = Color.gray300
        return label
    }

    fileprivate lazy var infoLabelsStackView: UIStackView = {
        let bandLabel = infoLabel(with: viewModel?.bandLabel)
        let channelLabel = infoLabel(with: viewModel?.channelLabel)
        let polarizationLabel = infoLabel(with: viewModel?.antennaLabel)

        let stackView = UIStackView(arrangedSubviews: [bandLabel, channelLabel, polarizationLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .lastBaseline
        stackView.spacing = 0
        return stackView
    }()

    func infoLabel(with text: String?) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = Color.black
        return label
    }

    // MARK: - Private Variables

    fileprivate var hasLaidOut: Bool = false

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let avatarHeight: CGFloat = 70
        static let height: CGFloat = 120
    }

    // MARK: - Initialization

    init() {
        let size = CGSize(width: UIScreen.main.bounds.width, height: Constants.height)
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = Color.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        guard !hasLaidOut else { return }

        addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.height.width.equalTo(Constants.avatarHeight)
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.centerY.equalToSuperview()
        }

        insertSubview(backgroundLabel, belowSubview: avatarImageView)
        backgroundLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        addSubview(legendLabelsStackView)
        legendLabelsStackView.snp.makeConstraints {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.centerY.equalToSuperview().offset(-Constants.padding)
        }

        addSubview(infoLabelsStackView)
        infoLabelsStackView.snp.makeConstraints {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.centerY.equalToSuperview().offset(Constants.padding/2)
        }

        let separatorLine = UIView()
        separatorLine.backgroundColor = Color.gray100
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.snp.bottom)
        }

        hasLaidOut = true
    }

    // MARK: - Content

    fileprivate func updateContent() {
        guard let viewModel = viewModel else { return }

        backgroundLabel.text = viewModel.shortChannelLabel

        func handleAvatarImage(_ image: UIImage?) {
            if image == nil {  avatarImageView.imageView.image = UIImage(named: "placeholder_large") }
        }
        
        let avatarImageSize = CGSize(width: Constants.avatarHeight, height: Constants.avatarHeight)
        let avatarPlaceholder = UIImage.image(withColor: Color.gray100, imageSize: avatarImageSize)
        if let avatarImageUrl = ImageUtil.getSizedUrl(viewModel.avatarUrl, size: avatarImageSize) {
            avatarImageView.imageView.setImage(with: avatarImageUrl, placeholderImage: avatarPlaceholder, size: avatarImageSize) { (image) in
                handleAvatarImage(image)
            }
        } else {
            handleAvatarImage(nil)
        }
    }
}
