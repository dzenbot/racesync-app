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
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true

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

    fileprivate lazy var rotatingIconView: RotatingIconView = {
        let view = RotatingIconView()
        view.tintColor = Color.yellow
        view.imageView.image = UIImage(named: "icn_trophy_qualifier")?.withRenderingMode(.alwaysTemplate)
        view.imageView.tintColor = Color.yellow
        return view
    }()

    fileprivate lazy var joinButton: JoinButton = {
        let button = JoinButton(type: .system)
        button.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        button.hitTestEdgeInsets = UIEdgeInsets(proportionally: -10)
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
        button.titleLabel?.numberOfLines = 2
        button.setImage(UIImage(named: "icn_pin_small"), for: .normal)
        button.imageView?.tintColor = button.tintColor
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(didPressLocationButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var dateButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.black
        button.shouldHighlight = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setImage(UIImage(named: "icn_calendar_small"), for: .normal)
        button.imageView?.tintColor = button.tintColor
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(didPressDateButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var headerLabelStackView: UIStackView = {
        var subviews = [UIView]()

        if canDisplayAddress { subviews += [locationButton] }
        subviews += [dateButton]

        let stackView = UIStackView(arrangedSubviews: subviews)
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
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)

        let separatorLine = UIView()
        separatorLine.backgroundColor = Color.gray100
        tableView.tableHeaderView = separatorLine
        separatorLine.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0.5)
            $0.width.equalToSuperview()
        }

        return tableView
    }()

    var canDisplayRaceIcon: Bool {
        return race.officialStatus == .approved
    }

    var canDisplayAddress: Bool {
        return raceViewModel.fullLocationLabel.count > 0
    }

    var canDisplayMap: Bool {
        return raceCoordinates != nil
    }

    var canDisplayDescription: Bool {
        return raceViewModel.race.description.count > 0
    }

    var canDisplayItinerary: Bool {
        return raceViewModel.race.itineraryContent.count > 0
    }

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
    fileprivate var raceCoordinates: CLLocationCoordinate2D?
    fileprivate let raceViewModel: RaceViewModel
    fileprivate let raceApi = RaceApi()
    fileprivate var chapterApi = ChapterApi()
    fileprivate var userApi = UserApi()

    // MARK: - Initialization

    init(with race: Race) {
        self.race = race
        self.raceViewModel = RaceViewModel(with: race)

        if let latitude = CLLocationDegrees(race.latitude), let longitude = CLLocationDegrees(race.longitude) {
            self.raceCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

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

        if canDisplayMap {
            contentView.addSubview(mapImageView)
            mapImageView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(-topOffset)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(Constants.mapHeight)
            }
        }

        if canDisplayRaceIcon {
            contentView.addSubview(rotatingIconView)
            rotatingIconView.snp.makeConstraints {
                if canDisplayMap {
                    $0.top.equalTo(mapImageView.snp.bottom).offset(Constants.padding*1.5)
                } else {
                    $0.top.equalToSuperview().offset(Constants.padding*1.5)
                }

                $0.leading.equalToSuperview().offset(Constants.padding)
                $0.width.height.equalTo(20)
            }
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            if canDisplayRaceIcon {
                $0.top.equalTo(rotatingIconView.snp.top)
                $0.leading.equalTo(rotatingIconView.snp.trailing).offset(Constants.padding/2)
            } else {
                if canDisplayMap {
                    $0.top.equalTo(mapImageView.snp.bottom).offset(Constants.padding*1.5)
                } else {
                    $0.top.equalToSuperview().offset(Constants.padding*1.5)
                }

                $0.leading.equalToSuperview().offset(Constants.padding)
            }

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

        if canDisplayDescription {
            contentView.addSubview(descriptionTextView)
            descriptionTextView.snp.makeConstraints {
                $0.top.equalTo(buttonStackView.snp.bottom).offset(Constants.padding)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.width.equalTo(view.bounds.width)
            }
        }

        contentView.addSubview(contentTextView)
        contentTextView.snp.makeConstraints {
            if canDisplayDescription {
                $0.top.equalTo(descriptionTextView.snp.bottom).offset(Constants.padding/2)
            } else {
                $0.top.equalTo(buttonStackView.snp.bottom).offset(Constants.padding)
            }
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(view.bounds.width)
        }

        if canDisplayItinerary {
            contentView.addSubview(itineraryTextView)
            itineraryTextView.snp.makeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(Constants.padding/2)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.width.equalTo(view.bounds.width)
            }
        }

        contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            if canDisplayItinerary {
                $0.top.equalTo(itineraryTextView.snp.bottom).offset(-Constants.padding)
            } else {
                $0.top.equalTo(contentTextView.snp.bottom).offset(-Constants.padding)
            }

            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.cellHeight*CGFloat(FormListType.allCases.count))
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
        dateButton.setTitle(raceViewModel.dateLabel, for: .normal)

        if canDisplayAddress {
            locationButton.setTitle(raceViewModel.fullLocationLabel, for: .normal)

            // Bring the icon to the first line, if there are more than 1 line of text
            if let label = locationButton.titleLabel, label.numberOfVisibleLines > 2 {
                locationButton.imageEdgeInsets = UIEdgeInsets(top: -Constants.padding, left: -Constants.padding, bottom: 0, right: 0)
            }
        }

        let textFont = UIFont.systemFont(ofSize: 15, weight: .regular)

        if canDisplayDescription {
            descriptionTextView.attributedText = try? NSAttributedString(HTMLString: raceViewModel.race.description, font: textFont, color: Color.gray300)
        }

        contentTextView.attributedText = try? NSAttributedString(HTMLString: raceViewModel.race.content, font: textFont)

        if canDisplayItinerary {
            itineraryTextView.attributedText = try? NSAttributedString(HTMLString: raceViewModel.race.itineraryContent, font: textFont)
        }

        // lays out the content and helps calculating the content size
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        
        scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height*3)

        loadMapIfPossible()
    }

    // MARK: - Actions

    @objc func didTapMapView(_ sender: UITapGestureRecognizer) {
        presentMapView()
    }

    @objc func didPressLocationButton(_ sender: UIButton) {
        guard canDisplayMap else { return }
        presentMapView()
    }

    @objc func didPressDateButton(_ sender: UITapGestureRecognizer) {
        guard let tabBarController = tabBarController as? RaceTabBarController else { return }
        tabBarController.didPressCalendarButton()
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        let currentState = sender.joinState

        toggleJoinButton(sender, forRace: raceViewModel.race, raceApi: raceApi) { [weak self] (newState) in

            if let tabBarController = self?.tabBarController as? RaceTabBarController, currentState != newState {
                tabBarController.reloadAllTabs()
            }
        }
    }
}

// MARK: - Map Logic

fileprivate extension EventDetailViewController {

    func loadMapIfPossible(_ showMapSnapshot: Bool = false) {
        guard let coordinates = raceCoordinates else { return }

        let distance = CLLocationDistance(1000)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: distance, longitudinalMeters: distance)

        let mapRect = MKCoordinateRegion.mapRectForCoordinateRegion(region)
        let paddedMapRect = mapRect.offsetBy(dx: 0, dy: -1500) // TODO: Convert Screen points to Map points instead of harcoded value

        let mapView = MKMapView()
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.showsUserLocation = false
        mapView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMapView))
        mapView.addGestureRecognizer(tapGestureRecognizer)

        let location = MKPointAnnotation()
        location.coordinate = coordinates
        mapView.addAnnotation(location)

        mapView.setVisibleMapRect(paddedMapRect, animated: false)

        // add temporairly to the view hiearchy so the map is displayed when loading
        // remove the map once the snapshot has been rendered
        scrollView.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-topOffset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.mapHeight)
        }

        if showMapSnapshot {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.loadMapSnapshot(with: mapView, mapRect: paddedMapRect, coordinate: coordinates)
            }
        }
    }

    func loadMapSnapshot(with mapView: MKMapView, mapRect: MKMapRect, coordinate: CLLocationCoordinate2D) {

        let snapShotOptions: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
        snapShotOptions.mapRect = mapRect
        snapShotOptions.size = mapViewSize
        snapShotOptions.scale = UIScreen.main.scale
        snapShotOptions.showsBuildings = mapView.showsBuildings
        snapShotOptions.showsPointsOfInterest = mapView.showsPointsOfInterest

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

    func presentMapView() {
        guard let coordinates = raceCoordinates, let address = race.address else { return }

        let mapVC = RaceMapViewController(with: coordinates, address: address)
        let mapNC = NavigationController(rootViewController: mapVC)

        present(mapNC, animated: true, completion: nil)
    }
}

// MARK: - UITableView Delegate

extension EventDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell else { return }

        if indexPath.row == FormListType.requirements.rawValue {
            // TODO: Push AircraftDetailViewController
        } else if indexPath.row == FormListType.chapter.rawValue {
            // TODO: Push ChapterViewController
        } else if indexPath.row == FormListType.owner.rawValue {
            cell.isLoading = true

            userApi.getUser(with: race.ownerId) { (user, error) in
                cell.isLoading = false

                if let user = user {
                    let userVC = UserViewController(with: user)
                    self.navigationController?.pushViewController(userVC, animated: true)
                } else if let _ = error {
                    // handle error
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableView DataSource

extension EventDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FormListType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell

        if indexPath.row == FormListType.requirements.rawValue {
            cell.textLabel?.text = "Aircraft Specs"
            let aircraftRaceSpecs = AircraftRaceSpecs(with: race)
            cell.detailTextLabel?.text = aircraftRaceSpecs.displayText()
        } else if indexPath.row == FormListType.chapter.rawValue {
            cell.textLabel?.text = "Chapter"
            cell.detailTextLabel?.text = race.chapterName
        } else if indexPath.row == FormListType.owner.rawValue {
            cell.textLabel?.text = "Race Coordinator"
            cell.detailTextLabel?.text = race.ownerUserName
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

// MARK: - MKMapView Delegate

extension EventDetailViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.image = UIImage(named: "icn_map_annotation")
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }

}

// MARK: - ScrollView Delegate

extension EventDetailViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canDisplayMap {
            stretchHeaderView(with: scrollView.contentOffset)
        }
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

fileprivate enum FormListType: Int, CaseIterable {
    case requirements, chapter, owner
}
