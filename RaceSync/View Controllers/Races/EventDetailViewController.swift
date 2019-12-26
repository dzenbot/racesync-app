//
//  EventDetailViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import MapKit
import RaceSyncAPI

class EventDetailViewController: UIViewController, Joinable {

    // MARK: - Private Variables

    fileprivate let mapViewSize = CGSize(width: UIScreen.main.bounds.width, height: Constants.mapHeight)

    fileprivate lazy var mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Color.clear

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMapView))
        imageView.addGestureRecognizer(tapGestureRecognizer)

        return imageView
    }()

    fileprivate lazy var titleLabel: PasteboardLabel = {
        let label = PasteboardLabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        label.textColor = Color.black
        label.numberOfLines = 2
        return label
    }()

    fileprivate lazy var joinButton: JoinButton = {
        let button = JoinButton(type: .system)
        button.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        return button
    }()

    fileprivate lazy var memberBadgeView: MemberBadgeView = {
        let view = MemberBadgeView(type: .system)
        view.isUserInteractionEnabled = false
        return view
    }()

    fileprivate lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [joinButton, memberBadgeView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .trailing
        stackView.spacing = 7
        return stackView
    }()

    fileprivate lazy var locationButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.red
        button.shouldHighlight = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.titleLabel?.numberOfLines = 3
        button.setImage(UIImage(named: "icn_pin_small"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: -Constants.padding, left: -Constants.padding, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(didPressLocationButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var dateButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.black
        button.shouldHighlight = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setImage(UIImage(named: "icn_calendar_small"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(didPressDateButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var headerLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [locationButton, dateButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 12
        return stackView
    }()

    fileprivate lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = Color.gray300
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = Constants.contentInsets
        return textView
    }()

    fileprivate lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = Color.black
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = Constants.contentInsets
        return textView
    }()

    fileprivate lazy var itineraryTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = Color.black
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = Constants.contentInsets
        return textView
    }()

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Color.white
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        return scrollView
    }()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        let separatorLine = UIView()
        separatorLine.backgroundColor = Color.gray100
        tableView.tableHeaderView = separatorLine
        separatorLine.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0.5)
            $0.width.equalToSuperview()
        }

        return tableView
    }()

    fileprivate var topOffset: CGFloat {
        get {
            let status_height = UIApplication.shared.statusBarFrame.height
            let navi_height = navigationController?.navigationBar.frame.size.height ?? 44
            return status_height + navi_height
        }
    }

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let contentInsets = UIEdgeInsets(top: padding/2, left: 10, bottom: padding/2, right: padding/2)
        static let mapHeight: CGFloat = 260
        static let cellHeight: CGFloat = 50
        static let minButtonSize: CGFloat = 72
    }

    fileprivate let race: Race
    fileprivate let raceViewModel: RaceViewModel
    fileprivate let raceApi = RaceApi()

    // MARK: - Initialization

    init(with race: Race) {
        self.race = race
        self.raceViewModel = RaceViewModel(with: race)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        populateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "Event Details"
        tabBarItem = UITabBarItem(title: "Event", image: UIImage(named: "icn_tab_details"), tag: 0)

        view.backgroundColor = Color.white

        let contentView = UIView()

        contentView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-topOffset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.mapHeight)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(mapImageView.snp.bottom).offset(Constants.padding*1.5)
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        contentView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.padding)
            $0.width.greaterThanOrEqualTo(Constants.minButtonSize)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        contentView.addSubview(headerLabelStackView)
        headerLabelStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.padding)
            $0.leading.equalToSuperview().offset(Constants.padding*1.5)
            $0.trailing.equalTo(buttonStackView.snp.leading).offset(-Constants.padding/2)
        }

        contentView.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(headerLabelStackView.snp.bottom).offset(Constants.padding/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }

        contentView.addSubview(contentTextView)
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom).offset(Constants.padding/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }

        contentView.addSubview(itineraryTextView)
        itineraryTextView.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(Constants.padding/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }

        contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(itineraryTextView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.cellHeight*2)
            $0.bottom.equalToSuperview().offset(-Constants.padding)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    fileprivate func populateData() {
        titleLabel.text = raceViewModel.titleLabel.uppercased()
        joinButton.joinState = raceViewModel.joinState
        memberBadgeView.count = raceViewModel.participantCount
        locationButton.setTitle(raceViewModel.fullLocationLabel, for: .normal)
        dateButton.setTitle(raceViewModel.fullDateLabel, for: .normal)

        let descriptionFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let captionFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionTextView.attributedText = try? NSMutableAttributedString(HTMLString: raceViewModel.race.description, font: descriptionFont, color: Color.gray300)
        contentTextView.attributedText = try? NSMutableAttributedString(HTMLString: raceViewModel.race.content, font: descriptionFont)
        itineraryTextView.attributedText = try? NSMutableAttributedString(HTMLString: raceViewModel.race.itineraryContent, font: captionFont)

        // lays out the content and helps calculating the content size
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height*3)

        if let latitude = CLLocationDegrees(raceViewModel.race.latitude), let longitude = CLLocationDegrees(raceViewModel.race.longitude) {
            loadMapSnapshot(with: latitude, longitude: longitude, useSnapshot: false)
        } else {
            // TODO: hide map view and adjust content inset
        }
    }

    fileprivate func loadMapSnapshot(with latitude: CLLocationDegrees, longitude: CLLocationDegrees, useSnapshot: Bool = true) {

        let distance = CLLocationDistance(1000)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: distance, longitudinalMeters: distance)

        let mapRect = MKCoordinateRegion.mapRectForCoordinateRegion(region)
        let paddedRect = mapRect.offsetBy(dx: 0, dy: -1500) // TODO: Convert Screen points to Map points instead of harcoded value

        let mapView = MKMapView()
        mapView.setVisibleMapRect(paddedRect, animated: false)

        // add temporairly to the view hiearchy so the map is displayed when loading
        // remove the map once the snapshot has been rendered
        scrollView.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-topOffset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.mapHeight)
        }

        guard useSnapshot else { return }

        let snapShotOptions: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
        snapShotOptions.mapRect = paddedRect
        snapShotOptions.size = mapViewSize
        snapShotOptions.scale = UIScreen.main.scale
        snapShotOptions.showsBuildings = true
        snapShotOptions.showsPointsOfInterest = false

        // Set MKMapSnapShotOptions to MKMapSnapShotter.
        let snapShotter: MKMapSnapshotter = MKMapSnapshotter(options: snapShotOptions)

        snapShotter.start { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else { return }

            let image = UIGraphicsImageRenderer(size: snapShotOptions.size).image { _ in
                snapshot.image.draw(at: .zero)

                guard let annotationImage = UIImage(named: "icn_map_annotation") else { return }

                var point = snapshot.point(for: coordinate)
                let rect = mapView.bounds

                if rect.contains(point) {
                    point.x -= annotationImage.size.width / 2
                    point.y -= annotationImage.size.height
                    annotationImage.draw(at: point)
                }
            }

            DispatchQueue.main.async {
                self.mapImageView.image = image
                mapView.removeFromSuperview()
            }
        }
    }

    // MARK: - Actions

    @objc func didTapMapView(_ sender: UITapGestureRecognizer) {
        print("didTapMapView!")
    }

    @objc func didPressLocationButton(_ sender: UITapGestureRecognizer) {
        print("didPressLocationButton!")
    }

    @objc func didPressDateButton(_ sender: UITapGestureRecognizer) {
        print("didPressDateButton!")
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        toggleJoinButton(sender, forRaceId: raceViewModel.race.id, raceApi: raceApi) { (newState) in
            // Do something
        }
    }
}

extension EventDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EventDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Color.gray50
        cell.selectedBackgroundView = selectedBackgroundView

        if indexPath.row == 0 {
            cell.textLabel?.text = "Chapter"
            cell.detailTextLabel?.text = race.chapterName
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Race Coordinator"
            cell.detailTextLabel?.text = race.ownerUserName
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

// MARK: - ScrollView Delegate

extension EventDetailViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stretchHeaderView(with: scrollView.contentOffset)
    }
}

// MARK: - HeaderStretchable

extension EventDetailViewController: HeaderStretchable {

    var targetHeaderView: UIView {
        return mapImageView
    }

    var targetHeaderViewSize: CGSize {
        return mapViewSize
    }

    var topLayoutInset: CGFloat {
        return topOffset
    }
}
