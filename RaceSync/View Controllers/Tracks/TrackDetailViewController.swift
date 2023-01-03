//
//  TrackDetailViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-04.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class TrackDetailViewController: UIViewController {

    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(cellType: FormTableViewCell.self)
        tableView.tableHeaderView = tableHeaderView

        tableHeaderView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(tableViewHeaderHeight)
        }

        return tableView
    }()

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(hex: "a0bb93")
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScrollView(_:)))
        scrollView.addGestureRecognizer(tapGesture)

        return scrollView
    }()

    fileprivate lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layoutManager.delegate = self
        textView.textColor = Color.gray400
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(Constants.padding/2, Constants.padding, Constants.padding, Constants.padding)
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: Color.red]
        textView.text = viewModel.track.description?.stripHTML() // adding raw text to allow calculating the height before laying out

        viewModel.track.description?.toHTMLAttributedString(textView.font, color: textView.textColor) { [weak self] (att) in
            textView.attributedText = att
        }
        return textView
    }()

    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.padding/2
        layout.minimumLineSpacing = Constants.padding/2
        layout.sectionInset = UIEdgeInsets(Constants.padding/2, Constants.padding, Constants.padding, Constants.padding)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: TrackElementViewCell.self)
        collectionView.register(cellType: TrackElementHeaderView.self, forSupplementaryViewOf: .header)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Color.white
        collectionView.isPagingEnabled = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    fileprivate lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.backgroundColor = Color.white
        control.pageIndicatorTintColor = Color.gray50
        control.currentPageIndicatorTintColor = Color.gray100
        control.hidesForSinglePage = false
        control.addTarget(self, action: #selector(didTapPageControl(_:)), for: .valueChanged)
        return control
    }()

    fileprivate lazy var tableHeaderView: UIView = {
        // need to define the height else the tableview doesn't lay out properly
        var frame = CGRect.zero
        frame.size.height = tableViewHeaderHeight

        let view = UIView(frame: frame)
        view.backgroundColor = Color.white

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.scrollHeight)
        }

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(scrollView.snp.bottom).offset(Constants.padding)
            $0.height.equalTo(Constants.pageControlHeight)
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()

            $0.top.equalTo(pageControl.snp.bottom)
            $0.size.equalTo(collectionViewContentSize(collectionView))
        }

        if let text = viewModel.track.description, !text.isEmpty {
            view.addSubview(descriptionTextView)
            descriptionTextView.snp.makeConstraints {
                $0.top.equalTo(collectionView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.width.equalTo(Constants.screenWidth)
            }
        }

        return view
    }()

    fileprivate var tableViewHeaderHeight: CGFloat {
        get {
            var height: CGFloat = 0
            height += Constants.scrollHeight
            height += Constants.pageControlHeight + Constants.padding
            height += collectionViewContentSize(collectionView).height
            height += descriptionTextViewHeight
            return CGFloat(Int(height))
        }
    }

    fileprivate var descriptionTextViewHeight: CGFloat {
        get {
            guard let text = viewModel.track.description, !text.isEmpty else { return 0 }
            let contentWidth = Constants.screenWidth - Constants.padding
            let height = descriptionTextView.sizeThatFits(CGSize(width: contentWidth, height: Constants.screenHeight)).height
            return CGFloat(Int(height))
        }
    }

    fileprivate lazy var verifyButton: JoinButton = {
        let button = JoinButton(type: .system)
        button.addTarget(self, action: #selector(didPressVerifyButton), for: .touchUpInside)
        button.hitTestEdgeInsets = UIEdgeInsets(proportionally: -Constants.padding)
        button.joinState = .joined
        button.setTitle("Verify", for: .normal)
        button.setImage(nil, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: Constants.padding, bottom: 6, right: Constants.padding)
        return button
    }()

    fileprivate var isVerificationEnabled: Bool {
        // make sure the validation urls are available
        guard viewModel.track.validationFeetUrl != nil || viewModel.track.validationMetersUrl != nil else { return false }

        // make sure the current user manages at least 1 chapter
        guard APIServices.shared.myChapter != nil else { return false }

        // make sure the track's season end date hasn't passed yet
        guard let endDate = viewModel.track.endDate else { return false }
        return !endDate.isPassed
    }

    fileprivate lazy var submitButton: JoinButton = {
        let button = JoinButton(type: .system)
        button.addTarget(self, action: #selector(didPressSubmitButton), for: .touchUpInside)
        button.hitTestEdgeInsets = UIEdgeInsets(proportionally: -Constants.padding)
        button.joinState = .joined
        button.setTitle("Submit Times", for: .normal)
        button.setImage(nil, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: Constants.padding, bottom: 6, right: Constants.padding)
        return button
    }()

    fileprivate var isSubmissionEnabled: Bool {
        guard viewModel.track.title.contains("UTT") else { return false } // only for UTT
        guard let _ = MGPWeb.getPrefilledUTT1LapPrefilledFormUrl(viewModel.track) else { return false }
        return true
    }

    fileprivate let viewModel: TrackViewModel
    fileprivate var userApi = UserApi()
    fileprivate var tableViewRows = [Row]()
    fileprivate var trackImages = [UIImage]()
    fileprivate var timer : DispatchSourceTimer? = nil
    fileprivate var didTapCell: Bool = false

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
        static let scrollHeight: CGFloat = 200
        static let pageControlHeight: CGFloat = 10
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
    }

    // MARK: - Initialization

    init(with viewModel: TrackViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        title = viewModel.titleLabel
        view.backgroundColor = Color.white

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        if isVerificationEnabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: verifyButton)
        } else if isSubmissionEnabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: submitButton)
        }

        loadRows()
        populateScrollView()
    }

    // MARK: - Actions

    fileprivate func showUserProfile(_ cell: FormTableViewCell) {
        guard !didTapCell, let username = viewModel.track.userName else { return }
        setLoading(cell, loading: true)

        userApi.searchUser(with: username) { [weak self] (user, error) in
            self?.setLoading(cell, loading: false)

            if let user = user {
                let vc = UserViewController(with: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            } else if let _ = error {
                // handle error
            }
        }
    }

    @objc func didTapScrollView(_ sender: Any) -> () {
        autoChangePages(false)

        let vc = GalleryViewController(images: trackImages, initialPage: pageControl.currentPage)
        vc.title = viewModel.titleLabel
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen

        UIViewController.topMostViewController()?.present(vc, animated: true, completion: nil)
    }

    @objc func didTapPageControl(_ sender: Any) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        let newOffset = CGPoint(x: x, y: 0)

        UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.scrollView.contentOffset = newOffset
        }, completion: nil)

        autoChangePages(false)
    }

    @objc func didPressVerifyButton(_ sender: JoinButton) {
        let pref = APIServices.shared.settings.measurementSystem

        if pref == .imperial, let url = viewModel.track.validationFeetUrl {
            WebViewController.openUrl(url)
        } else if let url = viewModel.track.validationMetersUrl {
            WebViewController.openUrl(url)
        }
    }

    @objc func didPressSubmitButton(_ sender: JoinButton) {
        let sheetTitle = "Submit UTT Lap Times"

        let alert = UIAlertController(title: sheetTitle, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = Color.blue

        alert.addAction(UIAlertAction(title: "1 Lap UTT", style: .default, handler: { [weak self] (actionButton) in
            guard let track = self?.viewModel.track, let url = MGPWeb.getPrefilledUTT1LapPrefilledFormUrl(track) else { return }
            WebViewController.openUrl(url)
        }))
        alert.addAction(UIAlertAction(title: "3 Lap UTT", style: .default, handler: { [weak self] (actionButton) in
            guard let track = self?.viewModel.track, let url = MGPWeb.getPrefilledUTT3LapPrefilledFormUrl(track) else { return }
            WebViewController.openUrl(url)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        UIViewController.topMostViewController()?.present(alert, animated: true)
    }

    func didPressTrackElement(at indexPath: IndexPath) {
        let element = viewModel.track.elements[indexPath.row]
        guard let image = loadImage(with: "spec_obstacle_\(element.type.rawValue)", subdirectory: "track-images") else { return }

        let vc = GalleryViewController(images: [image])
        vc.title = element.type.title
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        UIViewController.topMostViewController()?.present(vc, animated: true, completion: nil)
    }

    func setLoading(_ cell: FormTableViewCell, loading: Bool) {
        cell.isLoading = loading
        didTapCell = loading
    }

    fileprivate func autoChangePages(_ enable: Bool = true) {
        guard (enable && timer == nil) || (!enable && timer != nil) else { return }

        if enable {
            timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            timer?.schedule(deadline: .now() + .seconds(3), repeating: .seconds(5))
            timer?.setEventHandler {
                self.scrollToNextPage()
            }
            timer?.resume()
        } else {
            timer?.cancel()
            timer = nil
        }
    }

    fileprivate func scrollToNextPage(_ animated: Bool = true) {
        let currentPage: Int = Int(scrollView.contentOffset.x / Constants.screenWidth)
        var nextPage = currentPage + 1

        if currentPage == pageControl.numberOfPages-1 {
            nextPage = 0
        }

        let nextPos = Constants.screenWidth * CGFloat(nextPage)
        let newOffset = CGPoint(x: nextPos, y: 0)

        if animated {
            UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.scrollView.contentOffset = newOffset
            } completion: { (finished) in
                self.pageControl.currentPage = nextPage
            }
        } else {
            scrollView.contentOffset = newOffset
            pageControl.currentPage = nextPage
        }
    }
}

fileprivate extension TrackDetailViewController {

    // MARK: - Data Source

    func loadRows() {
        if viewModel.track.startDate != nil {
            tableViewRows += [Row.start]
        }
        if viewModel.track.endDate != nil {
            tableViewRows += [Row.end]
        }
        if viewModel.track.videoUrl != nil {
            tableViewRows += [Row.video]
        }
        if viewModel.track.leaderboardUrl != nil {
            tableViewRows += [Row.leaderboard]
        }
        if viewModel.track.userName != nil {
            tableViewRows += [Row.userName]
        }
    }

    func populateScrollView() {
        let images = loadImages(with: viewModel.track.id)
        guard images.count > 0 else { return }

        var hOffset: CGFloat = 0

        for i in 0..<images.count {
            let image = images[i]

            let imageView = UIImageView.init(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            scrollView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(hOffset)
                $0.width.height.equalToSuperview()
            }

            hOffset += Constants.screenWidth
        }

        pageControl.numberOfPages = images.count
        trackImages.append(contentsOf: images)

        autoChangePages()

        scrollView.contentSize = CGSize(width: hOffset, height: Constants.scrollHeight)
        scrollView.setNeedsLayout()
    }

    func getTrackImageURLs(with id: ObjectId) -> [URL] {
        var urls = [URL]()
        guard let furls = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "track-images") else { return urls }

        for furl in furls {
            let url = furl.absoluteString
            if url.contains("track-\(id)-") {

                // Honor measurement pref
                let pref = APIServices.shared.settings.measurementSystem
                let isImperial = url.contains("feet")
                let isMetric = url.contains("meters")

                if isImperial || isMetric {
                    if pref == .imperial && isImperial {
                        urls += [furl]
                    } else if pref == .metric && isMetric {
                        urls += [furl]
                    }
                } else {
                    urls += [furl]
                }
            }
        }

        // reversing the order, to display the non-metric diagram first
        return urls.sorted(by: { $0.absoluteString < $1.absoluteString })
    }

    func loadImages(with id: ObjectId) -> [UIImage] {
        var images = [UIImage]()
        let furls = getTrackImageURLs(with: id)

        for url in furls {
            if let imageData = try? Data(contentsOf: url) {
                let image = UIImage(data:imageData)!
                images.append(image)
            }
        }
        return images
    }

    func loadImage(with name: String, subdirectory: String? = nil) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: subdirectory) else { return nil }

        if let imageData = try? Data(contentsOf: url) {
            return UIImage(data:imageData)!
        }
        return nil
    }
}

// MARK: - UITableView Delegate

extension TrackDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell else { return }

        let row = tableViewRows[indexPath.row]
        let track = viewModel.track

        if row == .video {
            if let url = track.videoUrl {
                WebViewController.openUrl(url)
            }
        } else if row == .leaderboard {
            if let url = track.leaderboardUrl {
                WebViewController.openUrl(url)
            }
        } else if row == .userName {
            showUserProfile(cell)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableView DataSource

extension TrackDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell

        let row = tableViewRows[indexPath.row]
        let track = viewModel.track
        cell.textLabel?.text = row.title
        cell.isLoading = false

        if row == .start {
            cell.detailTextLabel?.text = viewModel.startDateLabel
            cell.accessoryType = .none
        } else if row == .end {
            cell.detailTextLabel?.text = viewModel.endDateLabel
            cell.accessoryType = .none
        } else if row == .video {
            if let url = track.videoUrl, let URL = URL(string: url) {
                cell.detailTextLabel?.text = URL.rootDomain
            }
        } else if row == .leaderboard {
            if let url = track.leaderboardUrl, let URL = URL(string: url) {
                cell.detailTextLabel?.text = URL.rootDomain
            }
        } else if row == .userName {
            cell.detailTextLabel?.text = track.userName
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

// MARK: UIScrollView Delegate

extension TrackDetailViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoChangePages(false)
    }
}

// MARK: UICollectionView DataSource

extension TrackDetailViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.track.elements.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TrackElementViewCell
        cell.element = viewModel.track.elements[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: .header, for: indexPath) as TrackElementHeaderView
        headerView.leftLabel.text = "\(viewModel.track.elementsCount) Elements"
        headerView.rightLabel.text = "\(viewModel.track.raceClass.title) Class"
        return headerView
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return collectionViewHeaderSize()
    }
}

// MARK: UICollectionView Delegate

extension TrackDetailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        didPressTrackElement(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }

        var width: CGFloat = 0
        width += Constants.screenWidth/2 // 2 items per row
        width -= flowLayout.minimumInteritemSpacing/2 + flowLayout.sectionInset.left

        var size: CGSize = .zero
        size.width = width
        size.height = TrackElementViewCell.minimumContentHeight
        return size
    }

    func collectionViewContentSize(_ collectionView: UICollectionView) -> CGSize {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }

        let elementsCount = viewModel.track.elements.count
        let rowsCount = CGFloat(elementsCount/2 + elementsCount%2)

        var height: CGFloat = 0
        height += TrackElementViewCell.minimumContentHeight * rowsCount // rows height
        height += flowLayout.minimumLineSpacing * (rowsCount-1) // spacing
        height += flowLayout.sectionInset.top + flowLayout.sectionInset.bottom // margin
        height += collectionViewHeaderSize().height // header height

        var size: CGSize = .zero
        size.width = Constants.screenWidth
        size.height = height
        return size
    }

    func collectionViewHeaderSize() -> CGSize {
        return CGSize(width: Constants.screenWidth, height: Constants.padding*2)
    }
}

// MARK: NSLayoutManager Delegate

extension TrackDetailViewController: NSLayoutManagerDelegate {

    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 5
    }
}

fileprivate enum Row: Int, EnumTitle {
    case start, end, video, leaderboard, userName

    var title: String {
        switch self {
        case .start:        return "Start of Season"
        case .end:          return "End of Season"
        case .video:        return "Video Preview"
        case .leaderboard:  return "Leaderboard"
        case .userName:     return "Designer"
        }
    }
}
