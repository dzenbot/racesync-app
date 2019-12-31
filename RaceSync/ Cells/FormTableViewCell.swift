//
//  FormTableViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-31.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class FormTableViewCell: UITableViewCell {

    static var identifier: String = "FormTableViewCell"

    // MARK: - Public Variables

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                accessoryView = spinnerView
                spinnerView.startAnimating()
            } else {
                accessoryView = nil
                accessoryType = .disclosureIndicator
            }
        }
    }

    static var height: CGFloat {
        return Constants.cellHeight
    }

    // MARK: - Private Variables

    fileprivate lazy var spinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)
        view.hidesWhenStopped = true
        view.color = Color.gray300
        return view
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Initializatiom

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
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
    }
}
