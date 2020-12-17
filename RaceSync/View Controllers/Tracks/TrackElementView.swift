//
//  TrackElementView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-07.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class TrackElementView: UIView {

    // MARK: - Public Variables

    let element: TrackElement

    // MARK: - Private Variables

    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = Color.black
        return label
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = Color.black
        return label
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: element.type.thumbnail)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 3
        return imageView
    }()


    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(element: TrackElement) {
        self.element = element
        super.init(frame: .zero)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupLayout() {
        backgroundColor = Color.gray20
        layer.cornerRadius = 6

        countLabel.text = String(element.count)
        titleLabel.text = element.type.title(with: element.count)

        addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding/2)
            $0.top.equalToSuperview().offset(Constants.padding*3/4)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding/2)
            $0.bottom.equalToSuperview().offset(-Constants.padding*3/4)
        }

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.padding/2)
            $0.centerY.equalToSuperview()
        }
    }

    override var intrinsicContentSize: CGSize {
        let width = UIScreen.main.bounds.width/2 - Constants.padding*1.5
        let height = imageView.frame.height + Constants.padding
        return CGSize(width: width, height: height)
    }
}

class TrackElementDummyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Color.gray20.withAlphaComponent(0.5)
        layer.cornerRadius = 6
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let width = UIScreen.main.bounds.width/2 - UniversalConstants.padding*1.5
        let height = 55 + UniversalConstants.padding
        return CGSize(width: width, height: height)
    }
}
