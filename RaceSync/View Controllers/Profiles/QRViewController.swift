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
        imageView.backgroundColor = Color.white
        imageView.contentMode = .center
        imageView.layer.cornerRadius = Constants.cornerRadius
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

    lazy var walletButton: UIButton = {
        let image = UIImage(named: "icn_apple_wallet")?.withRenderingMode(.alwaysOriginal)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.setTitle("Add To Apple Wallet", for: .normal)
        button.addTarget(self, action: #selector(didTapWalletButton), for: .touchUpInside)
        button.backgroundColor = Color.white
        button.tintColor = Color.blue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -Constants.padding)
        button.layer.cornerRadius = Constants.cornerRadius/2
        return button
    }()

    lazy var photosButton: UIButton = {
        let image = UIImage(named: "icn_apple_photos")?.withRenderingMode(.alwaysOriginal)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.setTitle("Save to Camera Roll", for: .normal)
        button.addTarget(self, action: #selector(didTapPhotosButton), for: .touchUpInside)
        button.backgroundColor = Color.white
        button.tintColor = Color.blue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -Constants.padding)
        button.layer.cornerRadius = Constants.cornerRadius/2
        return button
    }()

    fileprivate let userId: String

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let qrSize: CGSize = CGSize(width: 270, height: 270)
        static let imageSize: CGSize = CGSize(width: 320, height: 320)
        static let cornerRadius: CGFloat = 10
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

        view.addSubview(walletButton)
        walletButton.snp.makeConstraints {
            $0.top.equalTo(qrImageView.snp.bottom).offset(Constants.padding*3)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(qrImageView.snp.width).offset(-Constants.padding*4)
            $0.height.equalTo(50)
        }

        view.addSubview(photosButton)
        photosButton.snp.makeConstraints {
            $0.top.equalTo(walletButton.snp.bottom).offset(Constants.padding)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(qrImageView.snp.width).offset(-Constants.padding*4)
            $0.height.equalTo(50)
        }
    }

    // MARK: - Actions

    @objc func didTapView() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didTapImageView() {
        print("didTapImageView")
    }

    @objc func didTapWalletButton() {
        print("didTapWalletButton")
    }

    @objc func didTapPhotosButton() {
        guard let image = qrImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            AlertUtil.presentErrorMessage(error.localizedDescription, title: "Save error")
        } else {
            AlertUtil.presentAlertMessage("Your MultiGP QR has been saved to your Camera Roll.", title: "Saved!")
        }
    }
}
