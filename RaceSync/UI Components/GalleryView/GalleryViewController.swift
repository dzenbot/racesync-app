//
//  GalleryViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-18.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//
//  Inspired by https://github.com/justinvallely/SwiftPhotoGallery

import UIKit
import SnapKit

class GalleryViewController: UIViewController {

    // MARK: - Variables

    var images: [UIImage]
    var initialPage: Int

    // MARK: - Private Variables

    fileprivate lazy var collectionView: UICollectionView = {
        // Set up flow layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        // Set up collection view
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GalleryViewCell.self, forCellWithReuseIdentifier: "GalleryViewCell")
        collectionView.register(GalleryViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "GalleryViewCell")
        collectionView.register(GalleryViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GalleryViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Color.clear
        collectionView.isPagingEnabled = true
        collectionView.contentSize = CGSize(width: 1000, height: 1)
        collectionView.addGestureRecognizer(tapGesture)
        return collectionView
    }()

    fileprivate lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.numberOfPages = numberOfImages
        control.currentPageIndicatorTintColor = Color.white.withAlphaComponent(0.9)
        control.pageIndicatorTintColor = Color.white.withAlphaComponent(0.3)
        control.isHidden = numberOfImages <= 1
        return control
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

    fileprivate var currentPage: Int {
        set(page) {
            if page < numberOfImages {
                scrollToImage(withIndex: page, animated: false)
            } else {
                scrollToImage(withIndex: numberOfImages - 1, animated: false)
            }
            updatePageControl()
        }
        get {
            if isRevolvingCarouselEnabled {
                pageBeforeRotation = Int(collectionView.contentOffset.x / collectionView.frame.size.width) - 1
                return Int(collectionView.contentOffset.x / collectionView.frame.size.width) - 1
            } else {
                pageBeforeRotation = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
                return Int(collectionView.contentOffset.x / collectionView.frame.size.width)
            }
        }
    }

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    fileprivate var isRevolvingCarouselEnabled: Bool = true
    fileprivate var isViewFirstAppearing = true
    fileprivate var deviceInRotation = false
    fileprivate var pageBeforeRotation: Int = 0
    fileprivate var needsLayout = true
    fileprivate var timer : DispatchSourceTimer? = nil

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(images: [UIImage], initialPage: Int = 0) {
        self.images = images
        self.initialPage = initialPage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.images = [UIImage]()
        self.initialPage = 0
        super.init(coder: aDecoder)
    }

    // MARK: - View Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.black

        isRevolvingCarouselEnabled = numberOfImages > 1
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        if currentPage < 0 {
            currentPage = initialPage
        }

        isViewFirstAppearing = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if needsLayout {
            let desiredIndexPath = IndexPath(item: pageBeforeRotation, section: 0)

            if pageBeforeRotation >= 0 {
                scrollToImage(withIndex: pageBeforeRotation, animated: false)
            }

            collectionView.reloadItems(at: [desiredIndexPath])

            for cell in collectionView.visibleCells {
                if let cell = cell as? GalleryViewCell {
                    cell.configureForNewImage(animated: false)
                    cell.doubleTapGesture.delegate = self
                }
            }

            needsLayout = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return isChromeHidden
    }

    // MARK: Rotation Handling

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        deviceInRotation = true
        needsLayout = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .allButUpsideDown
        }
    }

    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }

    // MARK: - Layout

    func setupLayout() {

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Constants.padding)
        }

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top) //view.safeAreaInsets.top
        }
    }

    fileprivate var numberOfImages: Int {
        return images.count
    }

    fileprivate func getImage(currentPage: Int) -> UIImage {
        return images[currentPage]
    }

    fileprivate func updatePageControl() {
        pageControl.currentPage = currentPage
    }

    fileprivate func scrollToImage(withIndex: Int, animated: Bool = false) {
        collectionView.scrollToItem(at: IndexPath(item: withIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }

    fileprivate func reload(imageIndexes:Int...) {
        if imageIndexes.isEmpty {
            collectionView.reloadData()

        } else {
            let indexPaths: [IndexPath] = imageIndexes.map({IndexPath(item: $0, section: 0)})
            collectionView.reloadItems(at: indexPaths)
        }
    }

    fileprivate var isChromeHidden: Bool {
        return navigationBar.alpha < 1
    }

    fileprivate func toggleChrome() {
        hideChrome(!isChromeHidden, animated: true)
    }

    fileprivate func hideChrome(_ hide: Bool, delay: TimeInterval = 0, animated: Bool = false) {
        timer?.cancel()
        timer = nil

        func animate() {
            let alpha: CGFloat = hide ? 0 : 1
            let duration: TimeInterval = animated ? 1 : 0

            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: { () -> Void in
                self.pageControl.alpha = alpha
                self.navigationBar.alpha = alpha
                self.setNeedsStatusBarAppearanceUpdate()
            }, completion: nil)
        }

        if delay > 0 {
            timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            timer?.schedule(deadline: .now() + delay)
            timer?.setEventHandler {
                animate()
            }
            timer?.resume()
        } else {
            animate()
        }
    }

    // MARK: - Actions

    @objc fileprivate func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func didPressShareButton() {
        //
    }

    @objc func handleTapGesture(_ sender: UIGestureRecognizer) {
        hideChrome(!isChromeHidden)
    }
}


// MARK: UICollectionViewDataSource Methods
extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
        cell.image = getImage(currentPage: indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell

        switch kind {
        case UICollectionView.elementKindSectionFooter:
            cell.image = getImage(currentPage: 0)
        case UICollectionView.elementKindSectionHeader:
            cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
            if isViewFirstAppearing {
                cell.image = getImage(currentPage: 0)
            } else {
                cell.image = getImage(currentPage: numberOfImages - 1)
            }
        default:
            assertionFailure("Unexpected element kind")
        }

        return cell
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard isRevolvingCarouselEnabled else { return .zero }
        return UIScreen.main.bounds.size
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard isRevolvingCarouselEnabled else { return .zero }
        return UIScreen.main.bounds.size
    }
}


// MARK: UICollectionViewDelegate Methods

extension GalleryViewController: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideChrome(false)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // If the scroll animation ended, update the page control to reflect the current page we are on
        updatePageControl()
        hideChrome(true, delay: 2, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GalleryViewCell {
            cell.configureForNewImage(animated: false)
            cell.doubleTapGesture.delegate = self
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let cell = view as? GalleryViewCell else { return }
        collectionView.layoutIfNeeded()
        cell.configureForNewImage(animated: false)
        cell.doubleTapGesture.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).isEmpty && !deviceInRotation || (currentPage == numberOfImages && !deviceInRotation) {
            currentPage = 0
        }
        if !collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).isEmpty && !deviceInRotation || (currentPage == -1 && !deviceInRotation) {
            currentPage = numberOfImages - 1
        }
        deviceInRotation = false
    }
}

// MARK: UIGestureRecognizerDelegate Methods

extension GalleryViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UITapGestureRecognizer && gestureRecognizer is UITapGestureRecognizer {
            if gestureRecognizer == tapGesture && otherGestureRecognizer.view is UIScrollView {
                return true
            }
        }
        return false
    }
}
