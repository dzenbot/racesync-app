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

    fileprivate lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.backgroundColor = Color.white
        control.hidesForSinglePage = true
        control.pageIndicatorTintColor = Color.gray50
        control.currentPageIndicatorTintColor = Color.gray100
        return control
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
            $0.top.equalToSuperview()
        }

        let label2 = UILabel()
        label2.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label2.textColor = Color.blue
        label2.text = "\(viewModel.track.class.title) Class"
        label2.textAlignment = .right

        view.addSubview(label2)
        label2.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.top.equalToSuperview()
        }

        var subviews = [TrackElementView]()
        for e in viewModel.track.elements {
            let view = TrackElementView(element: e)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapElementView(_:)))
            view.addGestureRecognizer(tapGesture)

            subviews += [view]
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

            func addStackView(isLast: Bool = false) {
                view.addSubview(stackView)
                stackView.snp.makeConstraints {
                    $0.top.equalTo(label1.snp.bottom).offset(Constants.padding+(Constants.padding/2+subview.intrinsicContentSize.height)*CGFloat(row))
                    $0.leading.equalToSuperview().offset(Constants.padding)

                    if isLast {
                        $0.bottom.equalToSuperview().offset(-Constants.padding)
                        $0.width.equalTo(subview.intrinsicContentSize.width+Constants.padding/4)
                    } else {
                        $0.trailing.bottom.equalToSuperview().offset(-Constants.padding)
                    }
                }
            }

            let index = i+1

            // last item
            if index.isMultiple(of: 2) {
                addStackView()

                stackView = newStackView()
                row += 1
            } else if index == subviews.count {
                addStackView(isLast: true)
            }
        }

        return view
    }()

    fileprivate var tableViewHeaderHeight: CGFloat {
        get {
            var height: CGFloat = Constants.scrollHeight
            height += pageControl.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            height += elementsView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            height += Constants.padding * 3
            return height
        }
    }

    fileprivate lazy var tableHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constants.scrollWidth, height: tableViewHeaderHeight))
        view.backgroundColor = Color.white

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.scrollHeight)
        }

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(scrollView.snp.bottom).offset(Constants.padding/2)
        }

        view.addSubview(elementsView)
        elementsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(pageControl.snp.bottom)
        }

        return view
    }()

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

    fileprivate var didTapCell: Bool = false

    fileprivate let viewModel: TrackViewModel
    fileprivate var userApi = UserApi()
    fileprivate var tableViewRows = [Row]()
    fileprivate var trackImages = [UIImage]()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
        static let scrollHeight: CGFloat = 200
        static let scrollWidth: CGFloat = UIScreen.main.bounds.width
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
        populateContent()
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
        let image = trackImages[pageControl.currentPage]
        let vc = FullscreenImageViewController(image: image)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen

        UIViewController.topMostViewController()?.present(vc, animated: true, completion: nil)
    }

    @objc func didTapPageControl(_ sender: Any) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    @objc func didTapElementView(_ sender: Any) -> () {
        print("did tap element view!")

    }

    func setLoading(_ cell: FormTableViewCell, loading: Bool) {
        cell.isLoading = loading
        didTapCell = loading
    }

}

fileprivate extension TrackDetailViewController {

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

    func populateContent() {
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

            hOffset += Constants.scrollWidth
        }

        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: hOffset, height: scrollView.frame.size.height)

        pageControl.numberOfPages = images.count
        pageControl.addTarget(self, action: #selector(didTapPageControl(_:)), for: .valueChanged)

        trackImages.append(contentsOf: images)
    }

    func getTrackImageURLs(with id: ObjectId) -> [URL] {
        var urls = [URL]()
        guard let fURLs = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "Track-Diagrams") else { return urls }

        for URL in fURLs {
            let url = URL.absoluteString
            if url.contains("track-\(id)-") {

                // Honor measurement pref
                let pref = APIServices.shared.settings.measurementSystem
                let isImperial = url.contains("feet")
                let isMetric = url.contains("meters")

                if isImperial || isMetric {
                    if pref == .imperial && isImperial {
                        urls += [URL]
                    } else if pref == .metric && isMetric {
                        urls += [URL]
                    }
                } else {
                    urls += [URL]
                }
            }
        }

        // reversing the order, to display the non-metric diagram first
        return urls.sorted(by: { $0.absoluteString < $1.absoluteString })
    }

    func loadImages(with id: ObjectId) -> [UIImage] {
        var images = [UIImage]()
        let imageURLs = getTrackImageURLs(with: id)

        for URL in imageURLs {
            if let imageData = try? Data(contentsOf: URL) {
                let image = UIImage(data:imageData)!
                images.append(image)
            }
        }
        return images
    }

    func loadImage(with name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "jpg") else { return nil }
        return UIImage.init(contentsOfFile: path)
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
