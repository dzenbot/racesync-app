//
//  RichTextViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-04.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class RichTextViewController: UIViewController {

    // MARK: - Public Variables

    let formType: FormType = .textview

    var initialText: String

    // MARK: - Private Variables

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = Color.gray300
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.textContainerInset = Constants.contentInsets
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: Color.red]
        textView.delegate = self
        return textView
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let contentInsets = UIEdgeInsets(top: padding/2, left: 10, bottom: padding/2, right: padding/2)
    }

    // MARK: - Initialization

    init(with text: String) {

        initialText = text

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        view.backgroundColor = Color.white

        let rightBarButtonTitle = "Save"
        let rightBarButtonItem = UIBarButtonItem(title: rightBarButtonTitle, style: .done, target: self, action: #selector(didPressSaveButton))
        rightBarButtonItem.isEnabled = canSaveChanges()
        navigationItem.rightBarButtonItem = rightBarButtonItem

        view.addSubview(textView)
        textView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
            //$0.width.equalTo(view.bounds.width)
        }

        let font = textView.font
        let textColor = textView.textColor

        initialText.toHTMLAttributedString(font, color: textColor) { [weak self] (att) in
            self?.textView.attributedText = att
        }
    }

    // MARK: - Actions

    @objc func didPressSaveButton() {
        

    }

    func canSaveChanges() -> Bool {
        return false
    }
}

extension RichTextViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = canSaveChanges()
    }
}
