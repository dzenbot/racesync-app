//
//  FullscreenImageViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-08.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class FullscreenImageViewController: UIViewController {

    // MARK: - Private Variables

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture))
        doubleTapGesture.numberOfTapsRequired = 2

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.require(toFail: doubleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        tapGesture.require(toFail: tapGesture)

        scrollView.addGestureRecognizer(tapGesture)
        scrollView.addGestureRecognizer(doubleTapGesture)
        scrollView.addGestureRecognizer(longPressGesture)

        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.size.equalToSuperview()
        }

        return scrollView
    }()

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    fileprivate var image: UIImage?
    fileprivate var images: [UIImage]?
    fileprivate var initialIndex: Int = 0

    // MARK: - Initializers

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    init(images: [UIImage], initialIndex index: Int = 0) {
        self.images = images
        self.initialIndex = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }

    // MARK: - Layout

    func setupLayout() {
        view.backgroundColor = .black

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    func dismiss() {
        UIView.animate(withDuration: 0.1) {
            self.imageView.alpha = 0
        }

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Auto-rotation

    @objc func canRotate() -> Void {}
}

// MARK: - Touch Events

extension FullscreenImageViewController {

    @objc func handleTapGesture(_ sender: UIGestureRecognizer) {
        dismiss()
    }

    @objc func handleDoubleTapGesture(recognizer: UITapGestureRecognizer) {

        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let touchPoint = recognizer.location(in: view)
            let scrollViewSize = scrollView.bounds.size

            let width = scrollViewSize.width / scrollView.maximumZoomScale
            let height = scrollViewSize.height / scrollView.maximumZoomScale
            let x = touchPoint.x - (width/2.0)
            let y = touchPoint.y - (height/2.0)

            let rect = CGRect(x: x, y: y, width: width, height: height)
            scrollView.zoom(to: rect, animated: true)
        }
    }

    @objc func handleLongTap(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let saveAction: UIAlertAction = UIAlertAction(title: "Save Photo", style: .default) { [weak self] _ in
                self?.saveImage()
            }
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }

            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Image Handling

extension FullscreenImageViewController {

    func saveImage() {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Show HUD
    }
}

extension FullscreenImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if scrollView.zoomScale == 1 {
            if abs(velocity.x) > 0.25 || abs(velocity.y) > 0.25 {
                dismiss()
            }
        }
    }
}
