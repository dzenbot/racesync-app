//
//  RaceDetailViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import MapKit
import SnapKit
import SwiftValidators
import RaceSyncAPI

class RaceDetailViewController: UIViewController, ViewJoinable, RaceTabbable {

    // MARK: - Public Variables

    var race: Race

    // MARK: - Private Variables

    fileprivate lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.showsUserLocation = false
        mapView.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMapView))
        mapView.addGestureRecognizer(tapGestureRecognizer)

        return mapView
    }()

    fileprivate lazy var titleLabel: PasteboardLabel = {
        let label = PasteboardLabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        label.textColor = Color.black
        label.numberOfLines = 2
        return label
    }()

    fileprivate lazy var classLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = Color.gray300
        label.numberOfLines = 1
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
        view.addTarget(self, action: #selector(didPressMemberView), for: .touchUpInside)
        view.isUserInteractionEnabled = true
        return view
    }()

    fileprivate lazy var buttonStackView: UIStackView = {
        var subviews: [UIView] = [joinButton, memberBadgeView, funflyBadge]

        let stackView = UIStackView(arrangedSubviews: subviews)
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.titleLabel?.numberOfLines = 2
        button.setImage(UIImage(named: "icn_pin_small"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.imageView?.tintColor = button.tintColor
        button.addTarget(self, action: #selector(didPressLocationButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var startDateButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.black
        button.shouldHighlight = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.titleLabel?.numberOfLines = 2
        button.setImage(UIImage(named: "icn_calendar_start_small"), for: .normal) // 15 x 15
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.imageView?.tintColor = button.tintColor
        button.addTarget(self, action: #selector(didPressDateButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var endDateButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.black
        button.shouldHighlight = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.titleLabel?.numberOfLines = 2
        button.setImage(UIImage(named: "icn_calendar_end_small"), for: .normal) // 15 x 15
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.imageView?.tintColor = button.tintColor
        button.addTarget(self, action: #selector(didPressDateButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var funflyBadge: CustomButton = {
        let button = CustomButton()

        button.setTitle("Fun Fly", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(Color.white, for: .normal)
        button.tintColor = Color.white
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 12)
        button.backgroundColor = Color.lightBlue
        button.layer.cornerRadius = 6
        return button
    }()

    fileprivate lazy var headerLabelStackView: UIStackView = {
        var subviews = [UIView]()
        subviews += [startDateButton]
        if canDisplayEndDate { subviews += [endDateButton] }
        if canDisplayAddress { subviews += [locationButton] }

        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = Constants.padding
        return stackView
    }()

    fileprivate lazy var htmlView: RichEditorView = {
        let view = RichEditorView()
        view.isEditable = false
        view.isScrollEnabled = false
        view.delegate = self
        return view
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
        tableView.isScrollEnabled = false
        tableView.register(cellType: FormTableViewCell.self)

        let separatorLine = UIView()
        separatorLine.backgroundColor = Color.gray100
        tableView.tableHeaderView = separatorLine
        separatorLine.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0.5)
            $0.width.equalToSuperview()
        }
        return tableView
    }()

    fileprivate var raceCoordinates: CLLocationCoordinate2D? {
        if race.courseId != nil, let lat = CLLocationDegrees(race.latitude), let long = CLLocationDegrees(race.longitude) {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        return nil
    }

    fileprivate var canDisplayGQIcon: Bool {
        return race.officialStatus == .approved
    }

    fileprivate var canDisplayAddress: Bool {
        return raceViewModel.fullLocationLabel.count > 0
    }

    fileprivate var canDisplayEndDate: Bool {
        guard let text = raceViewModel.endDateDesc else { return false }
        return text.count > 0
    }

    fileprivate var canDisplayMap: Bool {
        return raceCoordinates != nil
    }

    fileprivate var canDisplayDescription: Bool {
        return raceViewModel.race.description.stripHTML().count > 0
    }

    fileprivate var canDisplayContent: Bool {
        return raceViewModel.race.content.stripHTML().count > 0
    }

    fileprivate var canDisplayItinerary: Bool {
        return raceViewModel.race.itinerary.stripHTML().count > 0
    }

    fileprivate var canDisplayFunFly: Bool {
        return raceViewModel.race.scoringDisabled
    }

    fileprivate var tableViewRows = [Row]()
    fileprivate var didTapCell: Bool = false

    fileprivate var raceViewModel: RaceViewModel
    fileprivate let raceApi = RaceApi()
    fileprivate var chapterApi = ChapterApi()
    fileprivate var userApi = UserApi()


    fileprivate var htmlViewHeightConstraint: Constraint?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let contentInsets = UIEdgeInsets(top: padding/2, left: 10, bottom: padding/2, right: padding/2)
        static let mapHeight: CGFloat = 260
        static let cellHeight: CGFloat = 50
        static let minButtonSize: CGFloat = 72
        static let buttonSpacing: CGFloat = 12
        static let htmlpadding: CGFloat = 12
    }

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        loadRows()
        populateContent()
        configureNavigationItems()

        let contentView = UIView()
        view.backgroundColor = Color.white

        // add temporairly to the view hiearchy so the map is displayed when loading
        // remove the map once the snapshot has been rendered
        if canDisplayMap {
            contentView.addSubview(mapView)
            mapView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(-topOffset)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(Constants.mapHeight)
            }
        }

        if canDisplayGQIcon {
            contentView.addSubview(rotatingIconView)
            rotatingIconView.snp.makeConstraints {
                if canDisplayMap {
                    $0.top.equalTo(mapView.snp.bottom).offset(Constants.padding*1.5)
                } else {
                    $0.top.equalToSuperview().offset(Constants.padding*1.5)
                }

                $0.leading.equalToSuperview().offset(Constants.padding)
                $0.width.height.equalTo(20)
            }
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            if canDisplayGQIcon {
                $0.top.equalTo(rotatingIconView.snp.top)
                $0.leading.equalTo(rotatingIconView.snp.trailing).offset(Constants.padding/2)
            } else {
                if canDisplayMap {
                    $0.top.equalTo(mapView.snp.bottom).offset(Constants.padding*1.5)
                } else {
                    $0.top.equalToSuperview().offset(Constants.padding*1.5)
                }
                $0.leading.equalToSuperview().offset(Constants.padding)
            }

            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        contentView.addSubview(classLabel)
        classLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.padding/2)
            $0.leading.equalTo(titleLabel.snp.leading)
        }

        contentView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.padding/2)
            $0.width.greaterThanOrEqualTo(Constants.minButtonSize)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        contentView.addSubview(headerLabelStackView)
        headerLabelStackView.snp.makeConstraints {
            $0.top.equalTo(classLabel.snp.bottom).offset(Constants.padding)
            $0.leading.equalToSuperview().offset(Constants.padding*1.5)
            $0.trailing.equalTo(buttonStackView.snp.leading).offset(-Constants.padding/2)
        }

        contentView.addSubview(htmlView)
        htmlView.snp.makeConstraints {
            $0.top.equalTo(headerLabelStackView.snp.bottom).offset(Constants.padding/2)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(view.bounds.width)

            htmlViewHeightConstraint = $0.height.equalTo(0).constraint
            htmlViewHeightConstraint?.activate()
        }

        contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(htmlView.snp.bottom).offset(Constants.padding/2)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.cellHeight*CGFloat(tableViewRows.count))
            $0.bottom.equalToSuperview() //.offset(-Constants.padding)
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

    fileprivate func loadRows() {

        tableViewRows = [Row]()

        if raceViewModel.classLabel != "" {
            tableViewRows += [Row.class]
        }

        tableViewRows += [Row.owner]

        if raceViewModel.chapterLabel != "" {
            tableViewRows += [Row.chapter]
        }

        if raceViewModel.seasonLabel != "" {
            tableViewRows += [Row.season]
        }

        // Only display ZippyQ link to schedule if it is configure for the race
        if race.maxZippyqDepth > 0 {
            tableViewRows += [Row.zippyQ]
        }

        if race.liveTimeEventUrl != nil {
            tableViewRows += [Row.results]
        }
    }

    fileprivate func populateContent() {

        titleLabel.text = raceViewModel.titleLabel.uppercased()
        classLabel.text = raceViewModel.classLabel
        joinButton.joinState = raceViewModel.joinState
        memberBadgeView.count = raceViewModel.participantCount
        startDateButton.setTitle(raceViewModel.startDateDesc , for: .normal)
        funflyBadge.isHidden = !canDisplayFunFly

        if canDisplayEndDate {
            endDateButton.setTitle(raceViewModel.endDateDesc, for: .normal)
        }

        if canDisplayAddress {
            locationButton.setTitle(raceViewModel.fullLocationLabel, for: .normal)

            // Bring the icon to the first line, if there are more than 1 line of text
            if let label = locationButton.titleLabel, label.numberOfVisibleLines > 2 {
                locationButton.imageEdgeInsets = UIEdgeInsets(top: -Constants.padding, left: -Constants.padding, bottom: 0, right: 0)
            }
        }

        // Load the HTML on the next runloop
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }

            var html = ""
            let spacing = 12

            if s.canDisplayDescription {
                html += "<div id=\"description\" style=\"color:\(Color.gray300.toHexString());\">\(s.race.description)</div>"
            }
            if s.canDisplayContent {
                html += "<div id=\"content\" style=\"padding-top: \(spacing)px; padding-bottom: \(spacing)px;\">\(s.race.content)</div>"
            }
            if s.canDisplayItinerary {
                html += "<hr style=\"border-top: 0.25px solid \(Color.gray100.toHexString());\">"
                html += "<div id=\"itinerary\" style=\"padding-top: \(spacing)px;\">\(s.race.itinerary)</div>"
            }

            s.htmlView.html = html
        }

        if canDisplayMap, let coordinates = raceCoordinates {
            let distance = CLLocationDistance(1000)
            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: distance, longitudinalMeters: distance)

            let mapRect = MKCoordinateRegion.mapRectForCoordinateRegion(region)
            let paddedMapRect = mapRect.offsetBy(dx: 0, dy: -1500) // TODO: Convert Screen points to Map points instead of harcoded value

            let location = MKPointAnnotation()
            location.coordinate = coordinates

            DispatchQueue.main.async {
                self.mapView.addAnnotation(location)
                self.mapView.setVisibleMapRect(paddedMapRect, animated: false)
            }
        }

        // lays out the content and helps calculating the content size
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        
        scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height)
    }

    fileprivate func configureNavigationItems() {
        title = "Race Details"
        tabBarItem = UITabBarItem(title: "Details", image: UIImage(named: "icn_tabbar_details"), selectedImage: nil)

        var buttons = [UIButton]()

        if race.canBeEdited {
            let editButton = CustomButton(type: .system)
            editButton.addTarget(self, action: #selector(didPressEditButton), for: .touchUpInside)
            editButton.setImage(ButtonImg.edit, for: .normal)
            buttons += [editButton]
        }

        if let _ = race.calendarEvent {
            let calendarButton = CustomButton(type: .system)
            calendarButton.addTarget(self, action: #selector(didPressCalendarButton), for: .touchUpInside)
            calendarButton.setImage(ButtonImg.calendar, for: .normal)
            buttons += [calendarButton]
        }

        let shareButton = CustomButton(type: .system)
        shareButton.addTarget(self, action: #selector(didPressShareButton), for: .touchUpInside)
        shareButton.setImage(ButtonImg.share, for: .normal)
        buttons += [shareButton]

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .lastBaseline
        stackView.spacing = Constants.buttonSpacing
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
    }

    // MARK: - Actions

    @objc fileprivate func didTapMapView(_ sender: UITapGestureRecognizer) {
        presentMapView()
    }

    @objc fileprivate func didPressLocationButton(_ sender: UIButton) {
        guard canDisplayMap else { return }
        presentMapView()
    }

    @objc func didPressDateButton(_ sender: UITapGestureRecognizer) {
        didPressCalendarButton()
    }

    @objc fileprivate func didPressJoinButton(_ sender: JoinButton) {
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: raceViewModel.race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                self?.race.isJoined = (newState == .joined)
                self?.reloadRaceView()
            }
        }
    }

    @objc fileprivate func didPressMemberView(_ sender: MemberBadgeView) {
        guard let tabBarController = tabBarController as? RaceTabBarController else { return }
        tabBarController.selectTab(.race)
    }

    @objc fileprivate func didPressEditButton() {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = Color.blue

        let editAction = UIAlertAction(title: "Edit Race", style: .default) { [weak self] action in
            self?.editRace()
        }
        alert.addAction(editAction)

        if race.canBeDuplicated {
            let duplicateAction = UIAlertAction(title: "Duplicate Race", style: .default) { [weak self] action in
                self?.duplicateRace()
            }
            alert.addAction(duplicateAction)
        }

        let deleteAction = UIAlertAction(title: "Delete Race", style: .destructive) { action in
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to delete \"\(self.race.name)\"?",
                                                          destructiveTitle: "Yes, Delete",
                                                          completion: { [weak self] (action) in
                self?.deleteRace()
            })
        }
        alert.addAction(deleteAction)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc fileprivate func didPressCalendarButton() {
        guard let event = race.calendarEvent else { return }

        ActionSheetUtil.presentActionSheet(withTitle: "Save the race details to your calendar?", buttonTitle: "Save to Calendar", completion: { (action) in
            CalendarUtil.add(event)
        })
    }

    @objc fileprivate func didPressShareButton() {
        guard let raceURL = URL(string: race.url) else { return }

        var items: [Any] = [raceURL]
        var activities: [UIActivity] = [CopyLinkActivity()]

        // Calendar integration
        if let event = race.calendarEvent {
            items += [event]
            activities += [CalendarActivity()]
        }

        activities += [MultiGPActivity()]

        let vc = UIActivityViewController(activityItems: items, applicationActivities: activities)
        vc.excludeAllActivityTypes(except: [.airDrop])
        present(vc, animated: true)
    }
}

extension RaceDetailViewController {

    func reloadContent() {

        let viewModel = RaceViewModel(with: race)

        joinButton.joinState = viewModel.joinState
        memberBadgeView.count = viewModel.participantCount
        raceViewModel = viewModel

        loadRows()
        populateContent()

        // updating the height of the tableview, since the number of rows could have changed
        tableView.snp.updateConstraints { make in
            make.height.equalTo(Constants.cellHeight*CGFloat(tableViewRows.count))
        }

        tableView.reloadData()
    }
}

fileprivate extension RaceDetailViewController {

    func presentMapView() {
        guard let coordinates = raceCoordinates, let address = race.address else { return }

        let vc = MapViewController(with: coordinates, address: address)
        vc.title = "Race Location"
        vc.showsDirection = true
        let nc = NavigationController(rootViewController: vc)
        present(nc, animated: true)
    }

    func editRace() {
        guard let chapters = APIServices.shared.myManagedChapters, chapters.count > 0 else { return }
        guard let chapter = chapters.filter ({ return $0.id == race.chapterId }).first else { return }

        let data = RaceData(with: race)
        let initialData = RaceData(with: race)

        let vc = RaceFormViewController(with: [chapter], raceData: data, initialRaceData: initialData, section: .general)
        vc.editMode = .update
        vc.delegate = self

        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
    }

    func duplicateRace() {
        guard let chapters = APIServices.shared.myManagedChapters, chapters.count > 0 else { return }

        let data = RaceData(with: race)

        let vc = RaceFormViewController(with: chapters, raceData: data, section: .general)
        vc.editMode = .new
        vc.delegate = self

        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
    }

    func deleteRace() {
        raceApi.deleteRace(with: race.id) { status, error in
            if status == true {
                self.navigationController?.popViewController(animated: true)
            } else if let error = error {
                AlertUtil.presentAlertMessage("Couldn't delete this race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
            }
        }
    }

    func reloadRaceView() {
        guard let tabBarController = tabBarController as? RaceTabBarController else { return }
        tabBarController.reloadRaceView()
    }

    func setLoading(_ cell: FormTableViewCell, loading: Bool) {
        cell.isLoading = loading
        didTapCell = loading
    }

    func canInteract(with cell: FormTableViewCell) -> Bool {
        guard !cell.isLoading else { return false }
        guard !didTapCell else { return false }
        return true
    }

    func showUserProfile(_ cell: FormTableViewCell) {
        guard canInteract(with: cell) else { return }
        setLoading(cell, loading: true)

        userApi.getUser(with: race.ownerId) { [weak self] (user, error) in
            if let user = user {
                let vc = UserViewController(with: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            } else if let _ = error {
                // handle error
            }
            self?.setLoading(cell, loading: false)
        }
    }

    func showClassRaces(_ cell: FormTableViewCell) {
        guard canInteract(with: cell) else { return }
        setLoading(cell, loading: true)

        let raceClass = race.raceClass

        raceApi.getRaces(forClass: raceClass, filters: [.upcoming]) { [weak self] (races, error) in
            if let races = races {
                let sortedViewModels = RaceViewModel.sortedViewModels(with: races, sorting: .descending)
                let vc = RaceListViewController(sortedViewModels, raceClass: raceClass)
                self?.navigationController?.pushViewController(vc, animated: true)
            } else if let _ = error {
                // handle error
            }
            self?.setLoading(cell, loading: false)
        }
    }

    func showSeasonRaces(_ cell: FormTableViewCell) {
        guard canInteract(with: cell), let seasonId = race.seasonId else { return }
        setLoading(cell, loading: true)

        raceApi.getRaces(forSeason: seasonId) { [weak self] (races, error) in
            if let races = races {
                let sortedViewModels = RaceViewModel.sortedViewModels(with: races)
                let vc = RaceListViewController(sortedViewModels, seasonId: seasonId)
                vc.title = self?.race.seasonName
                self?.navigationController?.pushViewController(vc, animated: true)
            } else if let _ = error {
                // handle error
            }
            self?.setLoading(cell, loading: false)
        }
    }

    func showChapterProfile(_ cell: FormTableViewCell) {
        guard canInteract(with: cell) else { return }
        setLoading(cell, loading: true)

        chapterApi.getChapter(with: race.chapterId) { [weak self] (chapter, error) in
            if let chapter = chapter {
                let vc = ChapterViewController(with: chapter)
                self?.navigationController?.pushViewController(vc, animated: true)
            } else if let _ = error {
                // handle error
            }
            self?.setLoading(cell, loading: false)
        }
    }

    func openRace(_ cell: FormTableViewCell) {
        guard canInteract(with: cell) else { return }
        setLoading(cell, loading: true)

        raceApi.open(race: race.id) { [weak self] (status, error) in
            if status {
                self?.race.status = .open
                self?.reloadRaceView()
            }
            self?.setLoading(cell, loading: false)
        }
    }

    func closeRace(_ cell: FormTableViewCell) {
        guard canInteract(with: cell) else { return }
        setLoading(cell, loading: true)

        raceApi.close(race: race.id) { [weak self] (status, error) in
            if status {
                self?.race.status = .closed
                self?.reloadRaceView()
            }

            self?.setLoading(cell, loading: false)
        }
    }

    func openZippyQSchedule(_ cell: FormTableViewCell) {
        guard race.zippyqUrl.count > 0 else { return }
        WebViewController.openUrl(race.zippyqUrl)
    }

    func openLiveFPV(_ cell: FormTableViewCell) {
        guard let url = race.liveTimeEventUrl else { return }
        WebViewController.openUrl(url)
    }
}

// MARK: - UITableView Delegate

extension RaceDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell else { return }
        let row = tableViewRows[indexPath.row]

        if row == .class {
            showClassRaces(cell)
        } else if row == .owner {
            showUserProfile(cell)
        } else if row == .chapter {
            showChapterProfile(cell)
        } else if row == .season {
            showSeasonRaces(cell)
        } else if row == .zippyQ {
            openZippyQSchedule(cell)
        } else if row == .results {
            openLiveFPV(cell)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableView DataSource

extension RaceDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell

        let row = tableViewRows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.isLoading = false

        if row == .class {
            cell.detailTextLabel?.text = raceViewModel.classLabel
        } else if row == .chapter {
            cell.detailTextLabel?.text = raceViewModel.chapterLabel
        } else if row == .owner {
            cell.detailTextLabel?.text = raceViewModel.ownerLabel
        } else if row == .season {
            cell.detailTextLabel?.text = raceViewModel.seasonLabel
        } else if row == .zippyQ {
            cell.detailTextLabel?.text = "multigp.com"
        } else if row == .results, let url = race.liveTimeEventUrl {
            if let web = AppWeb(url: url) {
                if web == .livefpv {
                    cell.accessoryView = UIImageView(image: UIImage(named: "logo_livefpv"))
                } else if web == .fpvscores {
                    cell.accessoryView = UIImageView(image: UIImage(named: "logo_fpvscores"))
                } else {
                    cell.detailTextLabel?.text = URL(string: url)?.rootDomain ?? ""
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

extension RaceDetailViewController: RaceFormViewControllerDelegate {

    func raceFormViewController(_ viewController: RaceFormViewController, didUpdateRace race: Race) {

        if viewController.editMode == .update {
            self.race = race
            self.reloadContent()
            viewController.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
            viewController.dismiss(animated: true, completion: nil)
        }
    }

    func raceFormViewControllerDidDismiss(_ viewController: RaceFormViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension RaceDetailViewController: RichEditorDelegate {

    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        var offset = CGFloat(height)
        offset += Constants.htmlpadding*2

        htmlViewHeightConstraint?.update(offset: offset)
    }

    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {

        if Validator.isEmail().apply(url.absoluteString) {
            // leave the system handle emails
            UIApplication.shared.open(url)
        } else {
            // open url using in-app browser, else the url is open on the WKWebView
            WebViewController.openURL(url)
        }

        return false
    }
}

// MARK: - MKMapView Delegate

extension RaceDetailViewController: MKMapViewDelegate {

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

fileprivate enum Row: Int, EnumTitle, CaseIterable {
    case `class`, chapter, owner, season, zippyQ, results

    var title: String {
        switch self {
        case .class:            return "Race Class"
        case .chapter:          return "Chapter"
        case .owner:            return "Coordinator"
        case .season:           return "Season"
        case .zippyQ:           return "ZippyQ Schedule"
        case .results:          return "View on"
        }
    }
}
