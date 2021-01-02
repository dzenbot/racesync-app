//
//  AircraftCollectionViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-08.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

protocol AircraftCollectionViewCellDelegate {
    func aircraftCollectionViewCellDidLongPress(_ cell: AircraftCollectionViewCell, at point: CGPoint)
}

class AircraftCollectionViewCell: UICollectionViewCell {

    static var height: CGFloat {
        return ((UIScreen.main.bounds.width - (Constants.padding * 3)) / 2)
    }

    lazy var avatarImageView: AvatarImageView = {
        let height = AircraftCollectionViewCell.height - Constants.padding*2
        let imageView = AvatarImageView(withHeight: height, showShadow: false)
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = Color.black
        label.textAlignment = .center
        return label
    }()

    var delegate: AircraftCollectionViewCellDelegate?

    // MARK: - Private Variables

    fileprivate lazy var avatarOverlay: UIView = {
        let view = UIView()
        view.layer.cornerRadius = avatarImageView.imageView.layer.cornerRadius
        view.backgroundColor = Color.black
        view.alpha = 0.0
        return view
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initializatiom

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override var isSelected: Bool {
        didSet {
            self.avatarOverlay.alpha = self.isSelected ? 0.4 : 0
        }
    }

    override var isHighlighted: Bool {
        didSet {
            guard !isSelected else { return }
            self.avatarOverlay.alpha = self.isHighlighted ? 0.4 : 0
        }
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(Constants.padding)
            $0.trailing.bottom.equalToSuperview().offset(-Constants.padding)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(Constants.padding/2)
            $0.leading.trailing.equalToSuperview()
        }

        contentView.addSubview(avatarOverlay)
        avatarOverlay.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalTo(avatarImageView)
        }
    }

    fileprivate func setupGestureRecognizers() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gestureRecognizer.minimumPressDuration = 0.75
        gestureRecognizer.delaysTouchesBegan = false
        contentView.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - Actions

    @objc fileprivate func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        let point = gestureRecognizer.location(in: contentView)
        delegate?.aircraftCollectionViewCellDidLongPress(self, at: point)
    }
}
