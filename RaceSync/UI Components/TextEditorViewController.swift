//
//  TextEditorViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-04.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

@objc protocol TextEditorViewControllerDelegate {
    func textEditorViewController(_ viewController: TextEditorViewController, didEditText text: String)
}

class TextEditorViewController: UIViewController {

    // MARK: - Public Variables

    weak var delegate: TextEditorViewControllerDelegate?

    // MARK: - Private Variables

    fileprivate lazy var textEditorView: RichEditorView = {
        let editorView = RichEditorView()
        editorView.placeholder = "Type something..."
        editorView.delegate = self
        return editorView
    }()

    fileprivate lazy var editorToolbar: RichEditorToolbar = {
        var rect = view.bounds
        rect.size.height = Constants.toolbarHeight

        let toolbar = RichEditorToolbar(frame: rect)
        toolbar.options = RichEditorDefaultOption.all
        toolbar.delegate = self
        return toolbar
    }()

    static let toolbarOptions: [RichEditorDefaultOption] = [
        .undo, .redo,
        .bold, .italic, .underline, .strike,
        .alignLeft, .alignCenter, .alignRight,
        //.textColor, .textBackgroundColor,
        .orderedList, .unorderedList, .indent, .outdent,
        .link, .image,
    ]

    fileprivate var initialText: String = ""
    fileprivate var newText: String = ""

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let toolbarHeight: CGFloat = 56
    }

    // MARK: - Initialization

    init(with text: String?) {
        initialText = text ?? ""
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

        textEditorView.inputAccessoryView = editorToolbar
        editorToolbar.editor = textEditorView

        view.addSubview(textEditorView)
        textEditorView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }

        textEditorView.html = initialText
    }

    // MARK: - Actions

    @objc func didPressSaveButton() {
        delegate?.textEditorViewController(self, didEditText: newText)
    }

    func canSaveChanges() -> Bool {
        return newText.count > 0 && newText != initialText
    }

    func updateSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = canSaveChanges()
    }
}

extension TextEditorViewController: RichEditorDelegate {

    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {

    }

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        newText = content
        updateSaveButton()
    }

    func richEditorTookFocus(_ editor: RichEditorView) {

    }

    func richEditorLostFocus(_ editor: RichEditorView) {

    }

    func richEditorDidLoad(_ editor: RichEditorView) {

    }

    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
        return false
    }
}

extension TextEditorViewController: RichEditorToolbarDelegate {

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {

        // TODO: Present a color picker
        toolbar.editor?.setTextColor(Color.red)
        updateSaveButton()
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {

        // TODO: Present a color picker
        toolbar.editor?.setTextBackgroundColor(Color.red)
        updateSaveButton()
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {

        let srcUrl = "Source Url"
        let imgDesc = "Image description"

        AlertUtil.presentAlertTextFields([srcUrl, imgDesc],
                                         title: "Insert Image",
                                         completion: { result in
            guard let url = result[srcUrl] else { return }
            let text = result[imgDesc] ?? ""

            toolbar.editor?.insertImage(url, alt: text)
            self.updateSaveButton()
        })
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {

        let linkUrl = "Link Url"
        let linkText = "Text to display"

        AlertUtil.presentAlertTextFields([linkUrl, linkText],
                                         title: "Insert Link",
                                         completion: { result in
            guard let url = result[linkUrl], var text = result[linkText] else { return }
            if text.count == 0 { text = url } // fixes inserting links when text is empty

            toolbar.editor?.insertLink(url, text: text)
            self.updateSaveButton()
        })
    }
}
