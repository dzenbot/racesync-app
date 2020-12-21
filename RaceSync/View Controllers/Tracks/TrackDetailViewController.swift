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
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
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
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScrollView(_:)))
        scrollView.addGestureRecognizer(tapGesture)

        return scrollView
    }()

    fileprivate lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = Color.gray400
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = Constants.contentInsets
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: Color.red]
        textView.text = viewModel.track.description

        viewModel.track.description?.toHTMLAttributedString(textView.font, color: textView.textColor) { [weak self] (att) in
            textView.attributedText = att
        }
        return textView
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
        view.backgroundColor = Color.clear

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.scrollHeight)
        }

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(scrollView.snp.bottom)
            $0.height.equalTo(Constants.pageControlHeight)
        }

        if let text = viewModel.track.description, !text.isEmpty {
            view.addSubview(descriptionTextView)
            descriptionTextView.snp.makeConstraints {
                $0.top.equalTo(pageControl.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.width.equalTo(Constants.screenWidth)
            }
        }

        view.addSubview(elementsView)
        elementsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()

            if let text = viewModel.track.description, !text.isEmpty {
                $0.top.equalTo(descriptionTextView.snp.bottom).offset(Constants.padding)
            } else {
                $0.top.equalTo(pageControl.snp.bottom)
            }
        }

        return view
    }()

    fileprivate lazy var elementsView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white

        let label1 = UILabel()
        label1.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label1.textColor = Color.gray200
        label1.text = "\(viewModel.track.elementsCount) Elements"

        view.addSubview(label1)
        label1.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.top.equalToSuperview().offset(Constants.padding/2)
        }

        let label2 = UILabel()
        label2.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label2.textColor = Color.blue
        label2.text = "\(viewModel.track.class.title) Class"
        label2.textAlignment = .right

        view.addSubview(label2)
        label2.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.top.equalToSuperview().offset(Constants.padding/2)
        }

        var subviews = [UIView]()
        for e in viewModel.track.elements {
            let view = TrackElementView(element: e)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTrackElementView(_:)))
            view.addGestureRecognizer(tapGesture)

            subviews += [view]
        }

        // adding an empty dummy view for the cases when the elements count is an off number
        // this is just to balance things visually
        if subviews.count%2 != 0 {
            subviews += [TrackElementDummyView()]
        }

        func newStackView() -> UIStackView {
            let view = UIStackView()
            view.axis = .horizontal
            view.distribution = .fillEqually
            view.alignment = .leading
            view.spacing = Constants.padding/2
            return view
        }

        var stackView = newStackView()
        var row: Int = 0

        for i in 0..<subviews.count {
            let subview = subviews[i]
            stackView.addArrangedSubview(subview)

            func addStackView(_ aStackView: UIStackView) {
                view.addSubview(aStackView)
                aStackView.snp.makeConstraints {
                    $0.top.equalTo(label1.snp.bottom).offset(Constants.padding+(Constants.padding/2+subview.intrinsicContentSize.height)*CGFloat(row))
                    $0.leading.equalToSuperview().offset(Constants.padding)
                    $0.trailing.bottom.equalToSuperview().offset(-Constants.padding)
                }
            }

            let index = i+1

            // last item
            if index.isMultiple(of: 2) {
                addStackView(stackView)

                if index != subviews.count {
                    stackView = newStackView()
                    row += 1
                }
            }
        }

        return view
    }()

    fileprivate var tableViewHeaderHeight: CGFloat {
        get {
            var height: CGFloat = 0
            height += Constants.scrollHeight
            height += Constants.padding
            height += Constants.pageControlHeight
            height += descriptionTextViewHeight
            height += elementsView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height 
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

    fileprivate lazy var verificationButton: JoinButton = {
        let button = JoinButton(type: .system)
        button.addTarget(self, action: #selector(didPressVerificationButton), for: .touchUpInside)
        button.hitTestEdgeInsets = UIEdgeInsets(proportionally: -Constants.padding)
        button.joinState = .joined
        button.setTitle("Verify", for: .normal)
        button.setImage(nil, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: Constants.padding, bottom: 6, right: Constants.padding)
        return button
    }()

    fileprivate var didTapCell: Bool = false

    fileprivate let viewModel: TrackViewModel
    fileprivate var userApi = UserApi()
    fileprivate var tableViewRows = [Row]()
    fileprivate var trackImages = [UIImage]()
    fileprivate var timer : DispatchSourceTimer? = nil

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
        static let scrollHeight: CGFloat = 200
        static let pageControlHeight: CGFloat = 32
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
        static let contentInsets = UIEdgeInsets(top: padding/2, left: 10, bottom: padding/2, right: padding/2)
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

        loadRows()
        setupLayout()
        populateScrollView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        if viewModel.track.validationFeetUrl != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: verificationButton)
        }
    }

    // MARK: - Actions

    func showUserProfile(_ cell: FormTableViewCell) {
        guard !didTapCell, let username = viewModel.track.designer else { return }
        setLoading(cell, loading: true)

        userApi.searchUser(with: username) { [weak self] (user, error) in
            self?.setLoading(cell, loading: false)

            if let user = user {
                let userVC = UserViewController(with: user)
                self?.navigationController?.pushViewController(userVC, animated: true)
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

    @objc func didPressVerificationButton(_ sender: JoinButton) {
        let pref = APIServices.shared.settings.measurementSystem

        if pref == .imperial, let url = viewModel.track.validationFeetUrl {
            WebViewController.openUrl(url)
        } else if let url = viewModel.track.validationMetersUrl {
            WebViewController.openUrl(url)
        }
    }

    @objc func didTapTrackElementView(_ sender: Any) -> () {
        guard let gesture = sender as? UIGestureRecognizer, let elementView = gesture.view as? TrackElementView else { return }
        guard let image = loadImage(with: "sepc_obstacle_\(elementView.element.type.rawValue)", subdirectory: "track-images") else { return }

        let vc = GalleryViewController(images: [image])
        vc.title = "Specs: \(elementView.element.type.title)"
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen

        UIViewController.topMostViewController()?.present(vc, animated: true, completion: nil)
    }

    func setLoading(_ cell: FormTableViewCell, loading: Bool) {
        cell.isLoading = loading
        didTapCell = loading
    }

    func autoChangePages(_ enable: Bool = true) {
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

    func scrollToNextPage(_ animated: Bool = true) {
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
        if viewModel.track.designer != nil {
            tableViewRows += [Row.designer]
        }
    }

    func populateScrollView() {
        title = viewModel.titleLabel
        view.backgroundColor = Color.white

        let images = loadImages(with: viewModel.track.id)
        guard images.count > 0 else { return }

        var hOffset: CGFloat = 0

        for i in 0..<images.count {
            let image = images[i]

            let imageView = UIImageView.init(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.tag = i

            scrollView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(hOffset)
                $0.top.bottom.width.height.equalToSuperview()
            }

            hOffset += Constants.screenWidth
        }

        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: hOffset, height: view.bounds.height)

        pageControl.numberOfPages = images.count

        trackImages.append(contentsOf: images)

        autoChangePages()
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
        } else if row == .designer {
            showUserProfile(cell)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TrackDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell

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
        } else if row == .designer {
            cell.detailTextLabel?.text = track.designer
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

extension TrackDetailViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoChangePages(false)
    }
}

fileprivate enum Row: Int, EnumTitle {
    case start, end, video, leaderboard, designer

    var title: String {
        switch self {
        case .start:        return "Start of Season"
        case .end:          return "End of Season"
        case .video:        return "Video Preview"
        case .leaderboard:  return "Leaderboard"
        case .designer:     return "Designer"
        }
    }
}
