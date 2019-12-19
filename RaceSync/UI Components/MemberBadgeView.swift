//
//  MemberBadgeView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class MemberBadgeView: CustomButton {

    var count: Int = 0 {
        didSet {
            setTitle("\(count)", for: .normal)
        }
    }

    // MARK: - Initializatiom

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout

    fileprivate func configureLayout() {
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        setTitleColor(Color.black, for: .normal)
        tintColor = Color.black

        setImage(UIImage(named: "icn_member"), for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -7, bottom: 0, right: 0)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 12)

        backgroundColor = Color.gray100
        layer.cornerRadius = 6
    }

    override var isSelected: Bool {
        didSet {
            // nothing
        }
    }
}
