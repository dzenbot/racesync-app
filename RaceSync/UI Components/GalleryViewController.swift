//
//  GalleryViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-08.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

class GalleryViewController: UIViewController {

    // MARK: - Public Variables

    var images: [UIImage]
    var initialPage: Int

    // MARK: - Private Variables

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        gestureRecognizer.require(toFail: doubleTapGesture)
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    fileprivate lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture))
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = Color.clear
        scrollView.delegate = self

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        scrollView.addGestureRecognizer(tapGesture)
        scrollView.addGestureRecognizer(doubleTapGesture)

        return scrollView
    }()

    fileprivate lazy var navigationBar: UINavigationBar = {
        let navigationBarAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [Self.self])
        let backgroundImage = UIImage.image(withColor: Color.clear, imageSize: CGSize(width: 44, height: 44))

        navigationBarAppearance.tintColor = Color.white
        navigationBarAppearance.barTintColor = Color.clear
        navigationBarAppearance.setBackgroundImage(backgroundImage, for: .default)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
                                                       NSAttributedString.Key.foregroundColor: Color.white]

        let bar = UINavigationBar()
        bar.clipsToBounds = true
        let navigationItem = UINavigationItem(title: title ?? "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_share"), style: .done, target: self, action: #selector(didPressShareButton))
        bar.setItems([navigationItem], animated: false)

        return bar
    }()

    fileprivate lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.backgroundColor = Color.clear
        control.pageIndicatorTintColor = Color.gray500
        control.currentPageIndicatorTintColor = Color.gray100
        control.hidesForSinglePage = true
        return control
    }()

    fileprivate var isChromeHidden: Bool = false

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
        static let scrollHeight: CGFloat = 200
        static let scrollWidth: CGFloat = UIScreen.main.bounds.width
    }

    // MARK: - Initialization

    public init(images: [UIImage], initialPage: Int = 0) {
        self.images = images
        self.initialPage = initialPage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return isChromeHidden
    }

    // MARK: - Layout

    func setupLayout() {
        view.backgroundColor = .black

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top) //view.safeAreaInsets.top
        }

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Constants.padding)
        }

        populateScrollView()
    }

    func populateScrollView() {
        guard images.count > 0 else { return }

        var hOffset: CGFloat = 0

        for i in 0..<images.count {
            let imageView = UIImageView.init(image: images[i])
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.tag = i

            scrollView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(hOffset)
                $0.top.bottom.width.height.equalToSuperview()
            }

            hOffset += Constants.scrollWidth
        }

        pageControl.numberOfPages = (images.count > 1) ? images.count : 0
        pageControl.currentPage = initialPage
        pageControl.addTarget(self, action: #selector(didTapPageControl(_:)), for: .valueChanged)

        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        scrollView.contentSize = appropriateScrollViewContentSize()

        if initialPage > 0 {
            scrollView.contentOffset = CGPoint(x: Constants.scrollWidth*CGFloat(initialPage), y: 0)
        }
    }

    func appropriateScrollViewContentSize() -> CGSize {
        guard images.count > 0 else { return .zero }

        let hOffset: CGFloat = Constants.scrollWidth * CGFloat(images.count)
        return CGSize(width: hOffset, height: view.bounds.height)
    }

    // MARK: - Actions

    @objc func didTapPageControl(_ sender: Any) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        let newOffset = CGPoint(x: x, y: 0)

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.scrollView.contentOffset = newOffset
        }, completion: nil)
    }

    @objc func handleTapGesture(_ sender: UIGestureRecognizer) {
        toggleChrome()
    }

    @discardableResult
    func toggleChrome() -> Bool {
        isChromeHidden = !isChromeHidden
        hideChrome(isChromeHidden, animated: true)
        return isChromeHidden
    }

    func hideChrome(_ hide: Bool, animated: Bool) {
        let alpha: CGFloat = hide ? 0 : 1

        if !hide {
            pageControl.isHidden = false
            navigationBar.isHidden = false
        }

        UIView.animate(withDuration: 0.2) {
            self.pageControl.alpha = alpha
            self.navigationBar.alpha = alpha
            self.setNeedsStatusBarAppearanceUpdate()
        } completion: { (finished) in
            self.pageControl.isHidden = hide
            self.navigationBar.isHidden = hide
        }
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

    @objc fileprivate func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func didPressShareButton() {
        //
    }

    func dismiss() {
        UIView.animate(withDuration: 0.1) {
            self.scrollView.alpha = 0
        }

        dismiss(animated: true, completion: nil)
    }

}

extension GalleryViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[pageControl.currentPage]
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if scrollView.zoomScale == 1 {
            scrollView.isPagingEnabled = false
            hide(true, views: scrollView.subviews, except: view)

            tapGesture.isEnabled = !toggleChrome()
        }
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == 1 {
            scrollView.isPagingEnabled = true
            hide(false, views: scrollView.subviews, except: nil)

            tapGesture.isEnabled = !toggleChrome()
            scrollView.contentSize = appropriateScrollViewContentSize()
        }
    }

    func hide(_ hide: Bool, views: [UIView], except view: UIView?) {
        for v in views {
            guard v != view else { continue }
//            v.isHidden = hide
            v.alpha = hide ? 0.5 : 1
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //
    }
}

extension GalleryViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
