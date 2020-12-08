//
//  TrackElementView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-07.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class TrackElementView: UIView {

    // MARK: - Private Variables

    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = Color.black
        return label
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = Color.black
        return label
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: elementImage)
        imageView.clipsToBounds = true
        return imageView
    }()

    var elementImage: UIImage? {
        get {
            switch element {
            case .gate:     return UIImage(named: "track_element_gate")
            case .flag:     return UIImage(named: "track_element_flag")
            default:        return nil
            }
        }
    }

    fileprivate let element: TrackElement
    fileprivate let count: Int

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(element: TrackElement, count: Int) {
        self.element = element
        self.count = count
        super.init(frame: .zero)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupLayout() {
        backgroundColor = Color.gray20

        countLabel.text = String(count)
        titleLabel.text = element.rawValue.capitalized

        addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.top.equalToSuperview().offset(Constants.padding/2)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.bottom.equalToSuperview().offset(-Constants.padding/2)
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
