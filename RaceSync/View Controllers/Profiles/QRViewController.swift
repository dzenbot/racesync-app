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
import PassKit

class QRViewController: UIViewController {

    // MARK: - Feature Flags
    fileprivate var isPassKitEnabled: Bool = true

    // MARK: - Private Variables

    fileprivate lazy var qrImageView: UIImageView = {
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

    fileprivate lazy var qrCodeLabel: PasteboardLabel = {
        let label = PasteboardLabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = Color.black
        label.textAlignment = .center
        return label
    }()

    fileprivate lazy var walletButton: UIButton = {
        let button = PKAddPassButton(addPassButtonStyle: .black)
        button.addTarget(self, action: #selector(didTapWalletButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var photosButton: UIButton = {
        let image = UIImage(named: "icn_apple_photos")?.withRenderingMode(.alwaysOriginal)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.setTitle("Save to Photos", for: .normal)
        button.addTarget(self, action: #selector(didTapPhotosButton), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        button.tintColor = Color.black
        button.backgroundColor = Color.white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -50, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.layer.cornerRadius = Constants.cornerRadius/2
        return button
    }()

    fileprivate lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: actionButtons())
        stackView.backgroundColor = .red
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = Constants.padding
        return stackView
    }()

    fileprivate func actionButtons() -> [UIView] {
        var subviews = [UIView]()
        if isPassKitEnabled { subviews += [walletButton] }
        subviews += [photosButton]
        return subviews
    }

    fileprivate let userId: String

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let qrSize: CGSize = CGSize(width: 270, height: 270)
        static let imageSize: CGSize = CGSize(width: 320, height: 320)
        static let cornerRadius: CGFloat = 24
        static let buttonHeight: CGFloat = 56
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

        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(qrImageView.snp.bottom).offset(Constants.padding*3)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Constants.imageSize.width)
            $0.height.greaterThanOrEqualTo(Constants.buttonHeight*2)
        }

        if walletButton.superview != nil {
            walletButton.snp.makeConstraints {
                $0.width.equalTo(Constants.imageSize.width)
                $0.height.equalTo(Constants.buttonHeight)
            }
        }

        photosButton.snp.makeConstraints {
            $0.width.equalTo(Constants.imageSize.width)
            $0.height.equalTo(Constants.buttonHeight)
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
        guard PKAddPassesViewController.canAddPasses() else { return }

        do {
            let pass = try PKPass(data: Data())
            guard let viewController = PKAddPassesViewController(pass: pass) else { return }
            UIViewController.topMostViewController()?.present(viewController, animated: true, completion: nil)
        }  catch {
            print("error showing pass \(error.localizedDescription)")
        }
    }

    @objc func didTapPhotosButton() {
        guard let image = qrImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            AlertUtil.presentErrorMessage(error.localizedDescription, title: "Save error")
        } else {
            AlertUtil.presentAlertMessage("Your MultiGP QR code has been saved to the Photos app!", title: "Saved Image")
        }
    }
}
