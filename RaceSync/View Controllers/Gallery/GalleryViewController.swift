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
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellType: GalleryViewCell.self)
        collectionView.register(cellType: GalleryViewCell.self, forSupplementaryViewOf: .footer)
        collectionView.register(cellType: GalleryViewCell.self, forSupplementaryViewOf: .header)
        collectionView.backgroundColor = Color.clear
        collectionView.isPagingEnabled = numberOfImages > 1
        collectionView.addGestureRecognizer(tapGesture)
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    fileprivate lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.backgroundColor = Color.clear
        control.numberOfPages = numberOfImages
        control.currentPageIndicatorTintColor = Color.white.withAlphaComponent(0.9)
        control.pageIndicatorTintColor = Color.white.withAlphaComponent(0.3)
        control.hidesForSinglePage = true
        control.addTarget(self, action: #selector(didTapPageControl), for: .valueChanged)
        return control
    }()

    fileprivate lazy var navigationBar: UINavigationBar = {
        let foregroundColor = Color.white
        let backgroundColor = Color.clear
        let backIndicatorImage = ButtonImg.back
        let backgroundImage = UIImage.image(withColor: backgroundColor, imageSize: CGSize(width: 44, height: 44))
        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
                              NSAttributedString.Key.foregroundColor: Color.black]

        let navigationItem = UINavigationItem(title: title ?? "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: ButtonImg.share, style: .done, target: self, action: #selector(didPressShareButton))

        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            navigationBarAppearance.titleTextAttributes = textAttributes
            navigationItem.standardAppearance = navigationBarAppearance
        }

        let barAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [Self.self])
        barAppearance.barTintColor = backgroundColor
        barAppearance.tintColor = foregroundColor
        barAppearance.barStyle = .default
        barAppearance.setBackgroundImage(backgroundImage, for: .default)
        barAppearance.isOpaque = false
        barAppearance.isTranslucent = true
        barAppearance.backIndicatorImage = backIndicatorImage?.withRenderingMode(.alwaysTemplate)
        barAppearance.backIndicatorTransitionMaskImage = backIndicatorImage
        barAppearance.titleTextAttributes = textAttributes

        let navBar = UINavigationBar()
        navBar.tintColor = Color.white
        navBar.clipsToBounds = true
        navBar.setItems([navigationItem], animated: false)

        return navBar
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    fileprivate lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    fileprivate var currentPage: Int {
        set(page) {
            setCurrentPage(page, animated: false)
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

    fileprivate var numberOfImages: Int {
        return images.count
    }

    fileprivate var isChromeHidden: Bool {
        return navigationBar.alpha < 1
    }

    fileprivate var isRevolvingCarouselEnabled: Bool = true
    fileprivate var isViewFirstAppearing = true
    fileprivate var deviceInRotation = false
    fileprivate var pageBeforeRotation: Int = 0
    fileprivate var needsLayout = false
    fileprivate var timer: DispatchSourceTimer? = nil

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtil.lockOrientation(.allButUpsideDown)

        if currentPage < 0 {
            currentPage = initialPage
        }

        isViewFirstAppearing = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if needsLayout {
            collectionView.collectionViewLayout.invalidateLayout()

            let desiredIndexPath = IndexPath(item: pageBeforeRotation, section: 0)

            collectionView.reloadItems(at: [desiredIndexPath])

            for cell in collectionView.visibleCells {
                if let cell = cell as? GalleryViewCell {
                    cell.configureForNewImage(animated: false)
                    cell.doubleTapGesture.delegate = self
                }
            }

            if pageBeforeRotation >= 0 {
                scrollToImage(withIndex: pageBeforeRotation, animated: false)
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

    // MARK: - Layout

    fileprivate func setupLayout() {

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Constants.padding)
            $0.height.equalTo(30)
        }

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }

    fileprivate func getImage(currentPage: Int) -> UIImage {
        guard currentPage >= 0 && currentPage < numberOfImages else { return UIImage() }
        return images[currentPage]
    }

    fileprivate func updatePageControl() {
        pageControl.currentPage = currentPage
    }

    fileprivate func setCurrentPage(_ page: Int, animated: Bool) {
        if page < numberOfImages {
            scrollToImage(withIndex: page, animated: animated)
        } else {
            scrollToImage(withIndex: numberOfImages - 1, animated: animated)
        }
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

    fileprivate func toggleChrome(animated: Bool = false) {
        hideChrome(!isChromeHidden, animated: animated)
    }

    fileprivate func hideChrome(_ hide: Bool, delay: TimeInterval = 0, animated: Bool = false) {
        guard hide != isChromeHidden else { return }

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
            // timer used to delay the fade-out animation. This was needed since UIView's animation API delay didn't affect the status bar.
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

    @objc func didTapPageControl(_ sender: Any) -> () {
        setCurrentPage(pageControl.currentPage, animated: true)
    }

    @objc fileprivate func didPressCloseButton() {
        // force the device orientation before dimissing, so there is no delay due to the animation
        AppUtil.lockOrientation(.portrait, andRotateTo: .portrait)

        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func didPressShareButton() {
        let vc = UIActivityViewController(activityItems: images, applicationActivities: nil)
        vc.excludedActivityTypes = [.assignToContact, .openInIBooks, .markupAsPDF]
        UIViewController.topMostViewController()?.present(vc, animated: true)
    }

    @objc fileprivate func handleTapGesture(_ sender: UIGestureRecognizer) {
        guard sender.state == .ended else { return }
        toggleChrome()
    }

    @objc fileprivate func handleLongPressGesture(_ sender: UIGestureRecognizer) {
        guard sender.state == .began else { return }
        didPressShareButton()
    }
}


// MARK: UICollectionView DataSource

extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GalleryViewCell
        cell.image = getImage(currentPage: indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard numberOfImages > 1 else { return UICollectionReusableView() }
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: .footer, for: indexPath) as GalleryViewCell
            cell.image = getImage(currentPage: 0)
            return cell
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: .header, for: indexPath) as GalleryViewCell
            if isViewFirstAppearing {
                cell.image = getImage(currentPage: 0)
            } else {
                cell.image = getImage(currentPage: numberOfImages - 1)
            }
            return cell
        default:
            assertionFailure("Unexpected element kind")
            return UICollectionReusableView()
        }
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard numberOfImages > 1 && isRevolvingCarouselEnabled else { return .zero }
        return UIScreen.main.bounds.size
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard numberOfImages > 1 && isRevolvingCarouselEnabled else { return .zero }
        return UIScreen.main.bounds.size
    }
}

// MARK: UICollectionView Delegate

extension GalleryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GalleryViewCell {
            cell.configureForNewImage(animated: false)
            cell.doubleTapGesture.delegate = self
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let cell = view as? GalleryViewCell else { return }
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
}

// MARK: UIScrollView Delegate

extension GalleryViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //hideChrome(false)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // If the scroll animation ended, update the page control to reflect the current page we are on
        updatePageControl()
        hideChrome(true, delay: 2, animated: true)
    }
}

// MARK: UIGestureRecognizer Delegate

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
