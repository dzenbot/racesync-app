//
//  AircraftCollectionViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-08.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class AircraftCollectionViewCell: UICollectionViewCell, ViewCellInterface {

    static var height: CGFloat {
        return ((UIScreen.main.bounds.width - (Constants.padding * 3)) / 2)
    }

    lazy var avatarImageView: AvatarImageView = {
        let height = AircraftCollectionViewCell.height - Constants.padding*2
        return AvatarImageView(withHeight: height, showShadow: false)
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = Color.black
        label.textAlignment = .center
        return label
    }()

    // MARK: - Private Variables

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initializatiom

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.avatarImageView.alpha = self.isSelected ? 0.6 : 1
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {

        }
    }

    // MARK: - Layout

    func setupLayout() {
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
    }
}
