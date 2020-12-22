//
//  TrackElementViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class TrackElementViewCell: UICollectionViewCell {

    // MARK: - Public Variables

    var element: TrackElement? {
        didSet {
            if let e = element {
                imageView.image = e.type.thumbnail
                countLabel.text = String(e.count)
                titleLabel.text = e.type.title(with: e.count)
            } else {
                imageView.image = nil
                countLabel.text = nil
                titleLabel.text = nil
            }
        }
    }

    static var minimumContentHeight: CGFloat {
        return Constants.imageHeight + Constants.padding
    }

    // MARK: - Private Variables

    fileprivate lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = Color.black
        return label
    }()

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = Color.black
        return label
    }()

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 3
        return imageView
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let imageHeight: CGFloat = 55
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

    fileprivate func setupLayout() {
        backgroundColor = Color.white
        contentView.backgroundColor = Color.gray20
        contentView.layer.cornerRadius = 6

        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding/2)
            $0.top.equalToSuperview().offset(Constants.padding*3/4)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding/2)
            $0.bottom.equalToSuperview().offset(-Constants.padding*3/4)
        }

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.padding/2)
            $0.centerY.equalToSuperview()
        }
    }

    override var isHighlighted: Bool {
       didSet {
        let alpha: CGFloat = isHighlighted ? 0.6 : 1
        let alpha2: CGFloat = isHighlighted ? 0.8 : 1

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
         self.imageView.alpha = alpha
         self.countLabel.alpha = alpha
         self.titleLabel.alpha = alpha
         self.contentView.alpha = alpha2
        }, completion: nil)
       }
   }
}
