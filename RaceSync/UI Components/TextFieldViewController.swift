//
//  TextFieldViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-19.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import PickerView
import Presentr

class TextFieldViewController: FormBaseViewController {

    // MARK: - Public Variables

    override var isLoading: Bool {
        didSet {
            if isLoading {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            else {
                navigationItem.rightBarButtonItem = rightBarButtonItem
                activityIndicatorView.stopAnimating()
            }
        }
    }

    override var formType: FormType {
        get { return .textfield }
        set { }
    }

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.keyboardType = .default
        textField.autocapitalizationType = .words
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = self.delegate?.formViewControllerKeyboardReturnKeyType?(self) ?? .done
        textField.textContentType = .nickname
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()

    // MARK: - Private Variables

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    fileprivate lazy var rightBarButtonItem: UIBarButtonItem = {
        let title = self.delegate?.formViewControllerRightBarButtonTitle?(self) ?? "OK"
        let barButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(didPressOKButton))
        barButtonItem.isEnabled = allowSelection(with: textField.text)
        return barButtonItem
    }()

    fileprivate var item: String?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with item: String? = nil) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async {
            self.textField.becomeFirstResponder()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        view.backgroundColor = Color.white

        textField.text = item

        if let nc = navigationController, nc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        }

        navigationItem.rightBarButtonItem = rightBarButtonItem

        view.addSubview(textField)
        textField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.padding*1.5)
            $0.leading.equalToSuperview().offset(Constants.padding*3)
            $0.trailing.equalToSuperview().offset(-Constants.padding*3)
        }
    }

    // MARK: - Actions

    @objc func didPressCloseButton() {
        dismiss(animated: true)
        delegate?.formViewControllerDidDismiss(self)
    }

    @objc func didPressOKButton() {
        let text = textField.text ?? ""
        delegate?.formViewController(self, didSelectItem: text)
    }
}

extension TextFieldViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        //
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)

        didChangeText(prospectiveText)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        didChangeText(nil)
        return true
    }

    func didChangeText(_ newText: String?) {
        let enabled = allowSelection(with: newText)

        navigationItem.rightBarButtonItem?.isEnabled = enabled
        textField.enablesReturnKeyAutomatically = enabled
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let enabled = allowSelection(with: textField.text)
        if enabled { didPressOKButton() }
        return enabled
    }

    func allowSelection(with text: String?) -> Bool {
        return delegate?.formViewController?(self, enableSelectionWithItem: text ?? "") ?? true
    }
}

extension TextFieldViewController: PresentrDelegate {

    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        DispatchQueue.main.async {
            self.delegate?.formViewControllerDidDismiss(self)
        }

        return true
    }
}
