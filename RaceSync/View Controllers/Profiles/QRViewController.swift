//
//  QRViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import SnapKit
import QRCode

class QRViewController: UIViewController {

    // MARK: - Private Variables

    lazy var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView)))

        imageView.addSubview(qrCodeLabel)
        qrCodeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.bottom.equalToSuperview().offset(-Constants.padding/2)
        }

        return imageView
    }()

    lazy var qrCodeLabel: PasteboardLabel = {
        let label = PasteboardLabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = Color.black
        label.textAlignment = .center
        return label
    }()

    fileprivate let userId: String

    fileprivate enum Constants {
        static let qrSize = CGSize(width: 270, height: 270)
        static let imageSize = CGSize(width: 320, height: 320)
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)

        var qrCode = QRCode(userId)
        qrCode?.size = Constants.qrSize
        qrImageView.image = qrCode?.image
        qrCodeLabel.text = userId

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        view.addSubview(qrImageView)
        qrImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.size.equalTo(Constants.imageSize)
        }
    }

    // MARK: - Actions

    @objc func didTapView() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didTapImageView() {
        //
    }

}
