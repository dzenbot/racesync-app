//
//  Shimmable.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import ShimmerSwift

protocol Shimmable {
    var tableView: UITableView { get }
    var shimmeringView: ShimmeringView { get }

    func isLoadingList(_ loading: Bool)
    static func defaultShimmeringView() -> ShimmeringView
}

extension Shimmable where Self: UIViewController {

    func isLoadingList(_ loading: Bool) {
        guard shimmeringView.isShimmering != loading else { return }
        
        shimmeringView.isShimmering = loading
        shimmeringView.isHidden = !loading
        view.isUserInteractionEnabled = !loading

        tableView.reloadData()
    }

    static func defaultShimmeringView() -> ShimmeringView {
        let view = ShimmeringView()
        view.contentView = tableViewCellShimmerView()
        view.shimmerAnimationOpacity = 0.4
        view.shimmerOpacity = 1.0
        view.shimmerPauseDuration = 0.3
        view.shimmerSpeed = 300
        view.backgroundColor = Color.white
        view.isHidden = true
        return view
    }

    static fileprivate func tableViewCellShimmerView() -> UIView {
        let view = UIView()
        guard let image = PlaceholderImg.shimmerList else { return view }

        let cellHeight = image.size.height
        let screenHeight = UIScreen.main.bounds.height
        let count: Int = abs(Int(screenHeight/cellHeight) + 1)

        for i in 0 ..< count {
            let imageView = UIImageView(image: image)

            if i > 0 {
                imageView.frame.origin.y = cellHeight * CGFloat(i-1)
            }

            view.addSubview(imageView)
        }

        return view
    }
}
