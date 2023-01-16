//
//  RichEditorOptionItem.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-04.
//
//  Heavily modified version of RichEditorView using WKWebView
//  https://github.com/Andrew-Chen-Wang/RichEditorView
//

import UIKit

/// A RichEditorOption object is an object that can be displayed in a RichEditorToolbar.
/// This protocol is proviced to allow for custom actions not provided in the RichEditorOptions enum.
protocol RichEditorOption {

    /// The image to be displayed in the RichEditorToolbar.
    var image: UIImage? { get }

    /// The title of the item.
    /// If `image` is nil, this will be used for display in the RichEditorToolbar.
    var title: String { get }

    /// The action to be evoked when the action is tapped
    /// - parameter editor: The RichEditorToolbar that the RichEditorOption was being displayed in when tapped.
    ///                     Contains a reference to the `editor` RichEditorView to perform actions on.
    func action(_ editor: RichEditorToolbar)
}

/// RichEditorOptionItem is a concrete implementation of RichEditorOption.
/// It can be used as a configuration object for custom objects to be shown on a RichEditorToolbar.
struct RichEditorOptionItem: RichEditorOption {

    /// The image that should be shown when displayed in the RichEditorToolbar.
    var image: UIImage?

    /// If an `itemImage` is not specified, this is used in display
    var title: String

    /// The action to be performed when tapped
    var handler: ((RichEditorToolbar) -> Void)

    init(image: UIImage?, title: String, action: @escaping ((RichEditorToolbar) -> Void)) {
        self.image = image
        self.title = title
        self.handler = action
    }
    
    // MARK: RichEditorOption
    
    func action(_ toolbar: RichEditorToolbar) {
        handler(toolbar)
    }
}

/// RichEditorOptions is an enum of standard editor actions
enum RichEditorDefaultOption: RichEditorOption {
    case clear
    case undo
    case redo
    case bold
    case italic
    case underline
    case checkbox
    case `subscript`
    case superscript
    case strike
    case textColor
    case textBackgroundColor
    case header(Int)
    case indent
    case outdent
    case orderedList
    case unorderedList
    case alignLeft
    case alignCenter
    case alignRight
    case image
    case video
    case link
    case table

    static let all: [RichEditorDefaultOption] = [
        .undo, .redo,
        .bold, .italic, .underline, .strike,
        .header(1), .header(2), .header(3), .header(4),
        .alignLeft, .alignCenter, .alignRight,
        //.textColor, .textBackgroundColor,
        .orderedList, .unorderedList, .indent, .outdent,
        .link, .image,
        .clear
    ]

    // MARK: RichEditorOption
    var image: UIImage? {
        var name = ""
        switch self {
        case .clear: name = "icns_toolbar_clear_format"
        case .undo: name = "icns_toolbar_undo"
        case .redo: name = "icns_toolbar_redo"
        case .bold: name = "icns_toolbar_bold"
        case .italic: name = "icns_toolbar_italic"
        case .underline: name = "icns_toolbar_underline"
        case .checkbox: name = "icns_toolbar_checkbox"
        case .subscript: name = "icns_toolbar_subscript"
        case .superscript: name = "icns_toolbar_superscript"
        case .strike: name = "icns_toolbar_strikethrough"
        case .textColor: name = "icns_toolbar_text_color"
        case .textBackgroundColor: name = "icns_toolbar_bg_color"
        case .header(let h): name = "icns_toolbar_h\(h)"
        case .indent: name = "icns_toolbar_indent"
        case .outdent: name = "icns_toolbar_outdent"
        case .orderedList: name = "icns_toolbar_ordered_list"
        case .unorderedList: name = "icns_toolbar_unordered_list"
        case .alignLeft: name = "icns_toolbar_justify_left"
        case .alignCenter: name = "icns_toolbar_justify_center"
        case .alignRight: name = "icns_toolbar_justify_right"
        case .image: name = "icns_toolbar_image"
        case .video: name = "icns_toolbar_insert_video"
        case .link: name = "icns_toolbar_link"
        case .table: name = "icns_toolbar_insert_table"
        }

        return UIImage(named: name)
    }
    
    var title: String {
        switch self {
        case .clear: return "Clear"
        case .undo: return "Undo"
        case .redo: return "Redo"
        case .bold: return "Bold"
        case .italic: return "Italic"
        case .underline: return "Underline"
        case .checkbox: return "Checkbox"
        case .subscript: return "Sub"
        case .superscript: return "Super"
        case .strike: return "Strike"
        case .textColor: return "Color"
        case .textBackgroundColor: return "BG Color"
        case .header(let h): return "H\(h)"
        case .indent: return "Indent"
        case .outdent: return "Outdent"
        case .orderedList: return "Ordered List"
        case .unorderedList: return "Unordered List"
        case .alignLeft: return "Left"
        case .alignCenter: return "Center"
        case .alignRight: return "Right"
        case .image: return "Image"
        case .video: return "Video"
        case .link: return "Link"
        case .table: return "Table"
        }
    }
    
    func action(_ toolbar: RichEditorToolbar) {
        switch self {
        case .clear:        toolbar.editor?.removeFormat()
        case .undo:         toolbar.editor?.undo()
        case .redo:         toolbar.editor?.redo()
        case .bold:         toolbar.editor?.bold()
        case .italic:       toolbar.editor?.italic()
        case .underline:    toolbar.editor?.underline()
        case .checkbox:     toolbar.editor?.checkbox()
        case .subscript:    toolbar.editor?.subscriptText()
        case .superscript:  toolbar.editor?.superscript()
        case .strike:       toolbar.editor?.strikethrough()
        case .textColor:    toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar)
        case .textBackgroundColor: toolbar.delegate?.richEditorToolbarChangeBackgroundColor?(toolbar)
        case .header(let h): toolbar.editor?.header(h)
        case .indent:       toolbar.editor?.indent()
        case .outdent:      toolbar.editor?.outdent()
        case .orderedList:  toolbar.editor?.orderedList()
        case .unorderedList: toolbar.editor?.unorderedList()
        case .alignLeft:    toolbar.editor?.alignLeft()
        case .alignCenter:  toolbar.editor?.alignCenter()
        case .alignRight:   toolbar.editor?.alignRight()
        case .image:        toolbar.delegate?.richEditorToolbarInsertImage?(toolbar)
        case .video:        toolbar.delegate?.richEditorToolbarInsertVideo?(toolbar)
        case .link:         toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
        case .table:        toolbar.delegate?.richEditorToolbarInsertTable?(toolbar)
        }
    }
}
