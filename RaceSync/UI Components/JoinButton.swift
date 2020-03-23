//
//  JoinButton.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class JoinButton: CustomButton {

    // MARK: - Public Variables

    /// Optional race id for callback usage
    var raceId: ObjectId?

    /// compact style to be used in small cells, with no interactivity
    var isCompact: Bool = false

    var joinState: JoinState = .join {
        didSet {
            if isCompact && joinState == .join {
                isHidden = true
                return
            } else {
                isHidden = false
            }

            let icon = joinState.icon?.image(withColor: joinState.titleColor.withAlphaComponent(isCompact ? 1 : 0.4))

            setTitle(isCompact ? nil : joinState.title, for: .normal)
            setTitleColor(joinState.titleColor, for: .normal)
            setImage(icon, for: .normal)
            backgroundColor = joinState.fillColor
            titleLabel?.font = joinState.font
            tintColor = joinState.titleColor
            imageView?.tintColor = joinState.titleColor
            isUserInteractionEnabled = !isCompact

            if let borderColor = joinState.outlineColor {
                layer.borderColor = borderColor.cgColor
                layer.borderWidth = 1
            } else {
                layer.borderWidth = 0
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            spinnerView.isHidden = !isLoading
            isUserInteractionEnabled = !isLoading
            animateSpinner(isLoading)

            // Since iOS7, setting titleLabel.hidden doesn't work anymore
            if isLoading {
                titleLabel?.removeFromSuperview()
                imageView?.removeFromSuperview()
            } else {
                if let label = titleLabel { addSubview(label) }
                if let imageView = imageView { addSubview(imageView) }
            }
        }
    }

    static let minHeight: CGFloat = 32
    static let minWidth: CGFloat = 76

    // MARK: - Private Variables

    fileprivate lazy var spinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)

        addSubview(view)
        view.snp.makeConstraints { (make) -> Void in
            make.centerX.centerY.equalToSuperview()
        }

        return view
    }()

    // MARK: - Initializatiom

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = true
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        layer.cornerRadius = 6
    }

    // MARK: - Animation

    fileprivate func animateSpinner(_ animate: Bool) {
        if animate && !spinnerView.isAnimating {
            spinnerView.color = joinState.titleColor
            spinnerView.startAnimating()
        } else if !animate && spinnerView.isAnimating {
            spinnerView.stopAnimating()
        }
    }

    // MARK: - Overrides

    override var intrinsicContentSize: CGSize {
        return CGSize(width: Self.minWidth, height: Self.minHeight)
    }

    override var isHighlighted: Bool {
        get {
            if !joinState.interactionEnabled {
                return false
            } else {
                return super.isHighlighted
            }
        }
        set {
            super.isHighlighted = newValue
        }
    }

    override var isSelected: Bool {
        get {
            if !joinState.interactionEnabled {
                return false
            } else {
                return super.isSelected
            }
        }
        set {
            super.isSelected = newValue
        }
    }

    override var isEnabled: Bool {
        didSet {
            // nothing
        }
    }

    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        guard joinState.interactionEnabled else { return }
        super.sendAction(action, to: target, for: event)
    }

    override func sendActions(for controlEvents: UIControl.Event) {
        guard joinState.interactionEnabled else { return }
        super.sendActions(for: controlEvents)
    }
}

extension JoinState {

    var icon: UIImage? {
        switch self {
        case .joined:   return UIImage(named: "icn_button_join")?.withRenderingMode(.alwaysOriginal)
        case .closed:   return UIImage(named: "icn_button_closed")?.withRenderingMode(.alwaysOriginal)
        default:        return nil
        }
    }

    var fillColor: UIColor {
        switch self {
        case .joined:   return Color.green
        case .join:     return Color.white
        case .closed:    return Color.gray100
        }
    }

    var outlineColor: UIColor? {
        switch self {
        case .join:     return Color.green
        default:        return nil
        }
    }

    var titleColor: UIColor {
        switch self {
        case .joined:   return Color.white
        case .join:     return Color.green
        case .closed:   return Color.black
        }
    }

    var font: UIFont {
        switch self {
        case .joined:   return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .join:     return UIFont.systemFont(ofSize: 14, weight: .bold)
        case .closed:   return UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }

    var interactionEnabled: Bool {
        switch self {
        case .closed:   return false
        default:        return true
        }
    }
}
