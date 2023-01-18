//
//  RacePilotsPickerController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-21.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import EmptyDataSet_Swift
import ShimmerSwift

protocol RacePilotsPickerControllerDelegate {
    func racePilotsPickerController(_ viewController: RacePilotsPickerController)
}

class RacePilotsPickerController: UIViewController, Shimmable {

    // MARK: - Public Variables

    var delegate: RacePilotsPickerControllerDelegate?

    var externalUserViewModels: [UserViewModel]? {
        didSet {
            if let viewModels = externalUserViewModels {
                joinedIds = viewModels.map({$0.userId})
            }
        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cellType: ChapterUserTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.tintColor = Color.gray400
        return tableView
    }()

    let shimmeringView: ShimmeringView = defaultShimmeringView()

    // MARK: - Private Variables

    fileprivate lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Filter pilots"
        searchBar.barTintColor = .white
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = Color.blue
        return searchBar
    }()

    fileprivate var race: Race
    fileprivate let raceApi = RaceApi()
    fileprivate var chapterApi = ChapterApi()
    fileprivate var userApi = UserApi()

    fileprivate var sections = [Section]()
    fileprivate var userViewModels = [UserViewModel]()
    fileprivate var searchResult = [UserViewModel]()
    fileprivate var joinedIds = [ObjectId]()
    fileprivate var didForceJoin: Bool = false

    fileprivate var emptyStateMembers = EmptyStateViewModel(.noChapterMembers)
    fileprivate var emptyStateSearch = EmptyStateViewModel(.noSearchResults)

    fileprivate var isSearching: Bool {
        guard let text = searchBar.text else { return false }
        return !text.isEmpty
    }

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let joinButtonTitle: String = "Force Join"
        static let avatarImageSize = CGSize(width: 50, height: 50)
        static let searchBarHeight: CGFloat = 56
    }

    // MARK: - Initialization

    init(with race: Race) {
        self.race = race

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if didForceJoin {
            delegate?.racePilotsPickerController(self)
        }
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "Add/Remove Pilots"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))

        view.backgroundColor = Color.white

        view.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(Constants.padding/2)
            $0.trailing.equalToSuperview().offset(-Constants.padding/2)
            $0.height.equalTo(Constants.searchBarHeight)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(shimmeringView)
        shimmeringView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc fileprivate func didPressJoinButton(_ sender: Any) {
        guard let button = sender as? JoinButton, let userId = button.objectId else { return }
        guard let viewModel = userViewModels.filter ({ return $0.userId == userId }).first else { return }

        button.isLoading = true
        let state = button.joinState

        if joinedIds.contains(viewModel.userId) {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Remove \(viewModel.username) from the race?", message: nil, destructiveTitle: "Yes, Remove", completion: { (action) in
                self.resignUser(with: userId) { (newState) in
                    button.isLoading = false

                    if state != newState {
                        button.joinState = newState
                        button.setTitle(Constants.joinButtonTitle, for: .normal)
                        self.joinedIds = self.joinedIds.filter { $0 != userId }
                        self.didForceJoin = true

                        RateMe.sharedInstance.userDidPerformEvent(showPrompt: true)
                    }
                }
            }) { (action) in
                 button.isLoading = false
            }
        } else {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Add \(viewModel.username) to the race?", destructiveTitle: "Yes, Add", completion: { (action) in
                self.forceJoinUser(with: userId) { (newState) in
                    button.isLoading = false

                    if state != newState {
                        button.joinState = newState
                        self.joinedIds += [userId]
                        self.didForceJoin = true

                        RateMe.sharedInstance.userDidPerformEvent(showPrompt: true)
                    }
                }
            }) { (action) in
                 button.isLoading = false
            }
        }
    }

    fileprivate func forceJoinUser(with id: ObjectId, completion: @escaping JoinStateCompletionBlock) {

        raceApi.forceJoin(race: race.id, pilotId: id) { [weak self] (status, error) in
            guard let strongSelf = self else { return }

            if status == true {
                completion(.joined)

                strongSelf.raceApi.checkIn(race: strongSelf.race.id, pilotId: id) { (raceEntry, error) in
                    // when joining a race, we checkin to get a frequency assigned
                }
            } else if let error = error {
                completion(.join)
                AlertUtil.presentAlertMessage("Couldn't add this user to the race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
            } else {
                completion(.join)
            }
        }
    }

    fileprivate func resignUser(with id: ObjectId, completion: @escaping JoinStateCompletionBlock) {

        raceApi.forceResign(race: race.id, pilotId: id) { (status, error) in
            if status == true {
                completion(.join)
            } else if let error = error {
                completion(.joined)
                AlertUtil.presentAlertMessage("Couldn't remove this user from the race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
            } else {
                completion(.joined)
            }
        }
    }

    @objc fileprivate func didPressCloseButton() {
        dismiss(animated: true)
    }
}

extension RacePilotsPickerController {

    fileprivate func loadUsers() {
        if userViewModels.isEmpty {
            isLoading(true)

            fetchUsers { [weak self] in
                self?.isLoading(false)
                self?.tableView.reloadData()
            }
        } else {
            tableView.reloadData()
        }
    }

    fileprivate func fetchUsers(_ completion: VoidCompletionBlock? = nil) {
        chapterApi.getChapterMembers(with: race.chapterId) { [weak self] (users, error) in
            if let users = users {
                let viewModels = UserViewModel.viewModels(with: users)
                self?.processUserViewModels(viewModels)
            } else {
                Clog.log("getMyRaces error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    fileprivate func processUserViewModels(_ viewModels: [UserViewModel]) {

        var combinedViewModels = viewModels

        if let models = externalUserViewModels {
            combinedViewModels += models
        }

        userViewModels = combinedViewModels.removingDuplicates()

        let groupedDictionary = Dictionary(grouping: userViewModels, by: { String($0.username.prefix(1).uppercased()) })
        let keys = groupedDictionary.keys.sorted()

        sections = keys.compactMap({ (key) -> Section in
            return Section(letter: key, viewModels: groupedDictionary[key]!.sorted())
        })
    }
}

extension RacePilotsPickerController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RacePilotsPickerController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching { return 1 }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isSearching else { return searchResult.count }
        return sections[section].viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return chapterUserViewCell(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversalConstants.cellHeight
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard !isSearching else { return nil }
        return sections.map { $0.letter }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isSearching else { return nil }
        return sections[section].letter
    }

    fileprivate func chapterUserViewCell(for indexPath: IndexPath) -> ChapterUserTableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as ChapterUserTableViewCell
        guard let viewModel = userViewModel(for: indexPath) else { return cell }

        cell.titleLabel.text = viewModel.pilotName
        cell.avatarImageView.imageView.setImage(with: viewModel.pictureUrl, placeholderImage: PlaceholderImg.medium, size: Constants.avatarImageSize)
        cell.subtitleLabel.text = viewModel.fullName

        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.joinButton.hitTestEdgeInsets = UIEdgeInsets(proportionally: -10)
        cell.joinButton.type = .race
        cell.joinButton.objectId = viewModel.userId

        if joinedIds.contains(viewModel.userId) {
            cell.joinButton.joinState = .joined
        } else {
            cell.joinButton.joinState = .join
            cell.joinButton.setTitle(Constants.joinButtonTitle, for: .normal)
        }

        return cell
    }

    fileprivate func userViewModel(for indexPath: IndexPath) -> UserViewModel? {
        if isSearching {
            return searchResult[indexPath.row]
        } else {
            let viewModels = sections[indexPath.section].viewModels
            return viewModels[indexPath.row]
        }
    }
}

extension RacePilotsPickerController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.lowercased()
        if !query.isEmpty {
            searchResult = userViewModels.filter({
                $0.username.localizedCaseInsensitiveContains(query) || $0.fullName.localizedCaseInsensitiveContains(query)
            })
        }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}

extension RacePilotsPickerController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if isSearching {
            return emptyStateSearch.title
        } else {
            return emptyStateMembers.title
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -scrollView.frame.height/10
    }
}

fileprivate struct Section {
    let letter : String
    let viewModels : [UserViewModel]
}
