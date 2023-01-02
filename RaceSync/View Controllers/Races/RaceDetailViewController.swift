//
//  RaceDetailViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import MapKit
import RaceSyncAPI

class RaceDetailViewController: UIViewController, ViewJoinable, RaceTabbable {

    // MARK: - Public Variables

    var race: Race
    var shouldShowMap: Bool = true

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
        view.addTarget(self, action: #selector(didPressMemberView), for: .touchUpInside)
        view.isUserInteractionEnabled = true
        return view
    }()

    fileprivate lazy var buttonStackView: UIStackView = {
        var subviews = [UIView]()
        subviews += [joinButton, memberBadgeView]
        if canDisplayFunFly { subviews += [funflyBadge] }

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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.titleLabel?.numberOfLines = 2
        button.setImage(UIImage(named: "icn_pin_small"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.padding, bottom: 0, right: 0)
        button.imageView?.tintColor = button.tintColor
        button.addTarget(self, action: #selector(didPressLocationButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var dateButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.tintColor = Color.black
        button.shouldHighlight = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.titleLabel?.numberOfLines = 1
        button.setImage(UIImage(named: "icn_calendar_small"), for: .normal)
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
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = Constants.contentInsets
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: Color.red]
        return textView
    }()

    fileprivate lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = Color.black
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = Constants.contentInsets
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: Color.red]
        return textView
    }()

    fileprivate lazy var itineraryTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = Color.black
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = Constants.contentInsets
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: Color.red]
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

    fileprivate var canDisplayGQIcon: Bool {
        return race.officialStatus == .approved
    }

    fileprivate var canDisplayAddress: Bool {
        return raceViewModel.fullLocationLabel.count > 0
    }

    fileprivate var canDisplayMap: Bool {
        return shouldShowMap && raceCoordinates != nil
    }

    fileprivate var canDisplayDescription: Bool {
        return raceViewModel.race.description.count > 0
    }

    fileprivate var canDisplayItinerary: Bool {
        return raceViewModel.race.itineraryContent.count > 0
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
    fileprivate var raceCoordinates: CLLocationCoordinate2D?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let contentInsets = UIEdgeInsets(top: padding/2, left: 10, bottom: padding/2, right: padding/2)
        static let mapHeight: CGFloat = 260
        static let cellHeight: CGFloat = 50
        static let minButtonSize: CGFloat = 72
        static let buttonSpacing: CGFloat = 12
    }

    // MARK: - Initialization

    init(with race: Race) {
        self.race = race
        self.raceViewModel = RaceViewModel(with: race)

        if race.courseId != nil, let latitude = CLLocationDegrees(race.latitude), let longitude = CLLocationDegrees(race.longitude) {
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
                $0.leading.trailing.equalToSuperview()
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
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(view.bounds.width)
        }

        if canDisplayItinerary {
            contentView.addSubview(itineraryTextView)
            itineraryTextView.snp.makeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(Constants.padding/2)
                $0.leading.trailing.equalToSuperview()
                $0.width.equalTo(view.bounds.width)
            }

            let separatorLine = UIView()
            separatorLine.backgroundColor = Color.gray100
            contentView.addSubview(separatorLine)
            separatorLine.snp.makeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(-Constants.padding/2)
                $0.height.greaterThanOrEqualTo(0.5)
                $0.width.equalToSuperview()
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
            $0.height.equalTo(Constants.cellHeight*CGFloat(tableViewRows.count))
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

    fileprivate func loadRows() {
        tableViewRows = [Row.requirements, Row.owner]

        if race.chapterName != "" {
            tableViewRows += [Row.chapter]
        }

        if race.seasonName != "" {
            tableViewRows += [Row.season]
        }

        tableViewRows += [Row.status]

        if race.liveTimeUrl != nil {
            tableViewRows += [Row.liveTime]
        }
    }

    fileprivate func populateContent() {
        titleLabel.text = raceViewModel.titleLabel.uppercased()
        joinButton.joinState = raceViewModel.joinState
        memberBadgeView.count = raceViewModel.participantCount
        dateButton.setTitle(raceViewModel.fullDateLabel, for: .normal)

        if canDisplayAddress {
            locationButton.setTitle(raceViewModel.fullLocationLabel, for: .normal)

            // Bring the icon to the first line, if there are more than 1 line of text
            if let label = locationButton.titleLabel, label.numberOfVisibleLines > 2 {
                locationButton.imageEdgeInsets = UIEdgeInsets(top: -Constants.padding, left: -Constants.padding, bottom: 0, right: 0)
            }
        }

        let race = raceViewModel.race
        let font = contentTextView.font

        // Chain HTML parsing from less expensive operations to the most.
        // This will make blocks of text to asynchrounsly load 1 by 1, but still be more efficient and not block the UI
        race.description.toHTMLAttributedString(font, color: descriptionTextView.textColor) { [weak self] (att) in
            self?.descriptionTextView.attributedText = att

            race.itineraryContent.toHTMLAttributedString(font) { [weak self] (att) in
                self?.itineraryTextView.attributedText = att

                race.content.toHTMLAttributedString(font) { [weak self] (att) in
                    self?.contentTextView.attributedText = att
                }
            }
        }

        if canDisplayMap {
            guard let coordinates = raceCoordinates else { return }

            let distance = CLLocationDistance(1000)
            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: distance, longitudinalMeters: distance)

            let mapRect = MKCoordinateRegion.mapRectForCoordinateRegion(region)
            let paddedMapRect = mapRect.offsetBy(dx: 0, dy: -1500) // TODO: Convert Screen points to Map points instead of harcoded value

            let location = MKPointAnnotation()
            location.coordinate = coordinates
            mapView.addAnnotation(location)
            mapView.setVisibleMapRect(paddedMapRect, animated: false)
        }

        // lays out the content and helps calculating the content size
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        
        scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height*3)
    }

    fileprivate func configureNavigationItems() {
        title = "Race Details"
        tabBarItem = UITabBarItem(title: "Details", image: UIImage(named: "icn_tabbar_details"), selectedImage: UIImage(named: "icn_tabbar_details_selected"))

        var buttons = [UIButton]()

        if race.isMyChapter {
            let editButton = CustomButton(type: .system)
            editButton.addTarget(self, action: #selector(didPressEditButton), for: .touchUpInside)
            editButton.setImage(UIImage(named: "icn_navbar_edit"), for: .normal)
            buttons += [editButton]
        }

        if let _ = race.calendarEvent {
            let calendarButton = CustomButton(type: .system)
            calendarButton.addTarget(self, action: #selector(didPressCalendarButton), for: .touchUpInside)
            calendarButton.setImage(UIImage(named: "icn_navbar_calendar"), for: .normal)
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

    public func reloadContent() {

        let viewModel = RaceViewModel(with: race)

        joinButton.joinState = viewModel.joinState
        memberBadgeView.count = viewModel.participantCount

        raceViewModel = viewModel
        tableView.reloadData()
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
        didPressCalendarButton()
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: raceViewModel.race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                self?.race.isJoined = (newState == .joined)
                self?.reloadRaceView()
            }
        }
    }

    @objc func didPressMemberView(_ sender: MemberBadgeView) {
        guard let tabBarController = tabBarController as? RaceTabBarController else { return }
        tabBarController.selectTab(.race)
    }

    @objc func didPressEditButton() {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = Color.blue

        let edit = UIAlertAction(title: "Edit Race", style: .default) { [weak self] action in
            self?.editRace()
        }

        let duplicate = UIAlertAction(title: "Duplicate Race", style: .default) { [weak self] action in
            self?.duplicateRace()
        }

        let delete = UIAlertAction(title: "Delete Race", style: .destructive) { action in
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to delete \"\(self.race.name)\"?",
                                                          destructiveTitle: "Yes, Delete",
                                                          completion: { [weak self] (action) in
                self?.deleteRace()
            })
        }

        alert.addAction(edit)
        alert.addAction(duplicate)
        alert.addAction(delete)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc func didPressCalendarButton() {
        guard let event = race.calendarEvent else { return }

        ActionSheetUtil.presentActionSheet(withTitle: "Save the race details to your calendar?", buttonTitle: "Save to Calendar", completion: { (action) in
            CalendarUtil.add(event)
        })
    }

    @objc func didPressShareButton() {
        guard let raceURL = URL(string: race.url) else { return }

        var items: [Any] = [raceURL]
        var activities: [UIActivity] = [CopyLinkActivity(), MultiGPActivity()]

        // Calendar integration
        if let event = race.calendarEvent {
            items += [event]
            activities += [CalendarActivity()]
        }

        let vc = UIActivityViewController(activityItems: items, applicationActivities: activities)
        vc.excludeAllActivityTypes(except: [.airDrop])
        present(vc, animated: true)
    }

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
        let vc = NewRaceViewController(with: [chapter], raceData: data, section: .general)
        vc.editMode = .edit

        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
    }

    func duplicateRace() {

    }

    func deleteRace() {

    }
}

fileprivate extension RaceDetailViewController {

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

    func toggleRaceStatus(_ cell: FormTableViewCell) {
        guard canInteract(with: cell) else { return }
        guard race.isMyChapter else { return } // only allow interacting if the user can manage the race

        if race.status == .open {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Close enrollment for this race?",
                                                          destructiveTitle: "Yes, Close",
                                                          completion: { [weak self] (action) in
                                                            self?.closeRace(cell)
            })
        } else {
            ActionSheetUtil.presentActionSheet(withTitle: "Open enrollment for this race?",
                                               buttonTitle: "Yes, Open",
                                               completion: { [weak self] (action) in
                                                self?.openRace(cell)
            })
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

    func openLiveTime(_ cell: FormTableViewCell) {
        guard let url = race.liveTimeUrl else { return }
        WebViewController.openUrl(url)
    }
}

// MARK: - UITableView Delegate

extension RaceDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell else { return }
        let row = tableViewRows[indexPath.row]

        if row == .requirements {
            // TODO: Push AircraftDetailViewController
        } else if row == .owner {
            showUserProfile(cell)
        } else if row == .chapter {
            showChapterProfile(cell)
        } else if row == .season {
            showSeasonRaces(cell)
        } else if row == .status {
            toggleRaceStatus(cell)
        } else if row == .liveTime {
            openLiveTime(cell)
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

        if row == .requirements {
            let aircraftRaceData = AircraftRaceData(with: race)
            cell.detailTextLabel?.text = aircraftRaceData.displayText()
        } else if row == .chapter {
            cell.detailTextLabel?.text = race.chapterName
        } else if row == .owner {
            cell.detailTextLabel?.text = race.ownerUserName
        } else if row == .season {
            cell.detailTextLabel?.text = race.seasonName
        } else if row == .status {
            cell.detailTextLabel?.text = race.status.title
        } else if row == .liveTime {
            cell.detailTextLabel?.text = ""
        }

        cell.isLoading = false

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
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
    case requirements, chapter, owner, season, status, liveTime

    var title: String {
        switch self {
        case .requirements:     return "Class"
        case .chapter:          return "Chapter"
        case .owner:            return "Coordinator"
        case .season:           return "Season"
        case .status:           return "Race Status"
        case .liveTime:         return "Go to LiveFPV.com"
        }
    }
}
