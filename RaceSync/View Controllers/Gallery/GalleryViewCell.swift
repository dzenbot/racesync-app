//
//  GalleryViewCell.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-18.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//
//  Inspired by https://github.com/justinvallely/SwiftPhotoGallery

import UIKit
import SnapKit

class GalleryViewCell: UICollectionViewCell {

    // MARK: - Public Variables

    var image: UIImage? {
        didSet {
            configureForNewImage(animated: false)
        }
    }

    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture))
        gestureRecognizer.numberOfTapsRequired = 2
        return gestureRecognizer
    }()

    // MARK: - Private Variables

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = Color.clear
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.addGestureRecognizer(doubleTapGesture)
        scrollView.delegate = self
        return scrollView
    }()

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func configureForNewImage(animated: Bool = true) {
        imageView.image = image
        imageView.sizeToFit()

        if animated {
            imageView.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.imageView.alpha = 1.0
            }
        }

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setZoomScale()
        scrollViewDidZoom(scrollView)
    }

    fileprivate func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height

        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = scrollView.minimumZoomScale
    }

    // MARK: - Actions

    @objc fileprivate func handleDoubleTapGesture(recognizer: UITapGestureRecognizer) {
        scrollView.toggleZoom(with: recognizer, animated: true)
    }
}


// MARK: UIScrollViewDelegate

extension GalleryViewCell: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {

        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let vPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let hPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0

        if vPadding >= 0 {
            // Center the image on screen
            scrollView.contentInset = UIEdgeInsets(top: vPadding, left: hPadding, bottom: vPadding, right: hPadding)
        } else {
            // Limit the image panning to the screen bounds
            scrollView.contentSize = imageViewSize
        }
    }
}
