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

protocol TextFieldViewControllerDelegate {
    func textFieldViewController(_ viewController: TextFieldViewController, didInputText text: String?)
    func textFieldViewControllerDidDismiss(_ viewController: TextFieldViewController)
}

class TextFieldViewController: UIViewController {

    // MARK: - Public Variables

    var delegate: TextFieldViewControllerDelegate?

    override var title: String? {
        didSet {
            navigationBarItem.title = title
        }
    }

    // MARK: - Private Variables

    fileprivate lazy var navigationBar: UINavigationBar = {
        let view = UINavigationBar()
        view.barTintColor = Color.clear
        view.items = [navigationBarItem]
        return view
    }()

    fileprivate lazy var navigationBarItem: UINavigationItem = {
        let item = UINavigationItem()
        item.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        item.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didPressSaveButton))
        item.rightBarButtonItem?.isEnabled = false
        return item
    }()

    fileprivate lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Aircraft Name"
        textField.keyboardType = .default
        textField.autocapitalizationType = .sentences
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.textContentType = .nickname
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()

    fileprivate var text: String?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with text: String? = nil) {
        self.text = text
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

    // MARK: - Layout

    func setupLayout() {
        view.backgroundColor = Color.white

        textField.text = text

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        view.addSubview(textField)
        textField.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(Constants.padding*1.5)
            $0.leading.equalToSuperview().offset(Constants.padding*3)
            $0.trailing.equalToSuperview().offset(-Constants.padding*3)
        }
    }

    // MARK: - Actions

    @objc func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
        delegate?.textFieldViewControllerDidDismiss(self)
    }

    @objc func didPressSaveButton() {
        let text = textField.text
        delegate?.textFieldViewController(self, didInputText: text)
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
        didChangeText(textField.text)
        return true
    }

    func didChangeText(_ newText: String?) {
        let canSave = (newText != text)
        navigationBarItem.rightBarButtonItem?.isEnabled = canSave
        textField.enablesReturnKeyAutomatically = canSave
    }

}
