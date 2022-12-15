//
//  TableViewCellShimmerView.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class TableViewCellShimmerView: UIView {

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupLayout() {
        guard let image = PlaceholderImg.shimmerList else { return }

        let cellHeight = image.size.height
        let screenHeight = UIScreen.main.bounds.height
        let count: Int = abs(Int(screenHeight/cellHeight) + 1)

        for i in 0 ..< count {
            let imageView = UIImageView(image: image)

            if i > 0 {
                imageView.frame.origin.y = cellHeight * CGFloat(i-1)
            }

            addSubview(imageView)
        }
    }
}
