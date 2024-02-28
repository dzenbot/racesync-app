//
//  RichEditorToolbar.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-04.
//
//  Heavily modified version of RichEditorView using WKWebView
//  https://github.com/Andrew-Chen-Wang/RichEditorView
//

import UIKit
import SnapKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
@objc protocol RichEditorToolbarDelegate {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Video toolbar item is pressed
    @objc optional func richEditorToolbarInsertVideo(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
    
    /// Called when the Insert Table toolbar item is pressed
    @objc optional func richEditorToolbarInsertTable(_ toolbar: RichEditorToolbar)
}

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
class RichEditorToolbar: UIView {

    /// The delegate to receive events that cannot be automatically completed
    weak var delegate: RichEditorToolbarDelegate?

    /// A reference to the RichEditorView that it should be performing actions on
    weak var editor: RichEditorView?

    /// The list of options to be displayed on the toolbar
    var options: [RichEditorOption] = [] {
        didSet { updateToolbar() }
    }

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    fileprivate lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.autoresizingMask = .flexibleWidth
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        return toolbar
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let buttonWidth: CGFloat = 28
    }

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: View
    
    func setupLayout() {
        autoresizingMask = .flexibleWidth
        backgroundColor = Color.navigationBarColor

        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = Color.gray100
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0.5)
            $0.width.equalToSuperview()
        }

        addSubview(scrollView)
        scrollView.addSubview(toolbar)

        updateToolbar()
    }
    
    func updateToolbar() {
        var buttons = [UIBarButtonItem]()

        for i in 0..<options.count {
            let option = options[i]
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }

            if let image = option.image {
                let button = RichBarButtonItem(image: image, handler: handler)
                buttons.append(button)
            } else {
                let title = option.title
                let button = RichBarButtonItem(title: title, handler: handler)
                buttons.append(button)
            }

            // adding space expect for the last item, with half space
            let spacing = (i < options.count-1) ? Constants.padding : Constants.padding/2

            if #available(iOS 14.0, *) {
                buttons.append(UIBarButtonItem.fixedSpace(spacing))
            } else {
                let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                space.width = spacing
                buttons.append(space)
            }
        }

        toolbar.items = buttons

        let width: CGFloat = buttons.reduce(0) { sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.width
            } else {
                return sofar + Constants.buttonWidth
            }
        }
        
        if width < frame.width {
            toolbar.frame.size.width = frame.width
        } else {
            toolbar.frame.size.width = width
        }

        toolbar.frame.size.height = bounds.height
        scrollView.contentSize.width = width
    }
}

fileprivate class RichBarButtonItem: UIBarButtonItem {

    var actionHandler: (() -> Void)?

    convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }

    convenience init(title: String = "", handler: (() -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
    }

    @objc func buttonWasTapped() {
        actionHandler?()
    }
}
