//
//  ForceJoinViewController.swift
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

protocol ForceJoinViewControllerDelegate {
    func forceJoinViewControllerDidForce(_ viewController: ForceJoinViewController)
}

class ForceJoinViewController: ViewController, Shimmable {

    // MARK: - Public Variables

    var delegate: ForceJoinViewControllerDelegate?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ChapterUserTableViewCell.self, forCellReuseIdentifier: ChapterUserTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = self.searchBar
        tableView.emptyDataSetSource = self
        tableView.tintColor = Color.gray400
        return tableView
    }()

    lazy var searchBar: UISearchBar = {
        let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 56)
        let frame = CGRect(origin: .zero, size: size)

        let searchBar = UISearchBar(frame: frame)
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Pilot"
        searchBar.barTintColor = .white
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()

    let shimmeringView: ShimmeringView = defaultShimmeringView()

    // MARK: - Private Variables

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
            delegate?.forceJoinViewControllerDidForce(self)
        }
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "Force Join Pilots"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))

        view.backgroundColor = Color.white

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(shimmeringView)
        shimmeringView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc fileprivate func didPressJoinButton(_ sender: Any) {
        guard let button = sender as? JoinButton, let userId = button.accessibilityIdentifier else { return }
        guard let viewModel = userViewModels.filter ({ return $0.user?.id == userId }).first, let user = viewModel.user else { return }

        button.isLoading = true
        let state = button.joinState

        if user.hasJoined(race) || joinedIds.contains(user.id) {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Resign \(viewModel.username) from the race?", message: nil, destructiveTitle: "Yes, resign", completion: { (action) in
                self.resignUser(with: userId) { (newState) in
                    button.isLoading = false

                    if state != newState {
                        button.joinState = newState
                        button.setTitle("Force Join", for: .normal)
                        self.joinedIds = self.joinedIds.filter { $0 != userId }
                        self.didForceJoin = true
                    }
                }
            }) { (action) in
                 button.isLoading = false
            }
        } else {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Force join \(viewModel.username) to the race?", destructiveTitle: "Yes, force join", completion: { (action) in
                self.forceJoinUser(with: userId) { (newState) in
                    button.isLoading = false

                    if state != newState {
                        button.joinState = newState
                        self.joinedIds += [userId]
                        self.didForceJoin = true
                    }
                }
            }) { (action) in
                 button.isLoading = false
            }
        }
    }

    fileprivate func forceJoinUser(with id: ObjectId, completion: @escaping JoinStateCompletionBlock) {

        raceApi.forceJoin(race: race.id, pilotId: id) { (status, error) in
            if status == true {
                completion(.joined)
                // TODO: Reload race entries
            } else if let error = error {
                completion(.join)
                AlertUtil.presentAlertMessage("Couldn't force join this user to the race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
            } else {
                completion(.join)
            }
        }
    }

    fileprivate func resignUser(with id: ObjectId, completion: @escaping JoinStateCompletionBlock) {

        raceApi.forceResign(race: race.id, pilotId: id) { (status, error) in
            if status == true {
                completion(.join)
                // TODO: Reload race entries
            } else if let error = error {
                completion(.joined)
                AlertUtil.presentAlertMessage("Couldn't remove this user from the race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
            } else {
                completion(.joined)
            }
        }
    }

    @objc fileprivate func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension ForceJoinViewController {

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
        chapterApi.getUsers(with: race.chapterId) { [weak self] (users, error) in
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
        userViewModels = viewModels.sorted { $0.username.lowercased() < $1.username.lowercased() }

        let groupedDictionary = Dictionary(grouping: viewModels, by: { String($0.username.prefix(1).uppercased()) })
        let keys = groupedDictionary.keys.sorted()

        sections = keys.compactMap({ (key) -> Section in
            return Section(letter: key, viewModels: groupedDictionary[key]!.sorted())
        })
    }
}

extension ForceJoinViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ForceJoinViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching { return 1 }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isSearching else { return searchResult.count }
        guard sections.count > 0 else { return 0 }
        return sections[section].viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            let viewModels = searchResult[indexPath.row]
            return tableViewCell(for: viewModels)
        } else {
            let viewModels = sections[indexPath.section].viewModels
            return tableViewCell(for: viewModels[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChapterUserTableViewCell.height
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard !isSearching else { return nil }
        guard sections.count > 0 else { return nil }
        return sections.map { $0.letter }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isSearching else { return nil }
        guard sections.count > 0 else { return nil }
        return sections[section].letter
    }

    fileprivate func tableViewCell(for viewModel: UserViewModel) -> ChapterUserTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChapterUserTableViewCell.identifier) as! ChapterUserTableViewCell
        guard let user = viewModel.user else { return cell }

        cell.titleLabel.text = viewModel.pilotName
        cell.avatarImageView.imageView.setImage(with: viewModel.pictureUrl, placeholderImage: UIImage(named: "placeholder_medium"))
        cell.subtitleLabel.text = viewModel.fullName

        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.joinButton.hitTestEdgeInsets = UIEdgeInsets(proportionally: -10)
        cell.joinButton.accessibilityIdentifier = user.id

        if user.hasJoined(race) || joinedIds.contains(user.id) {
            cell.joinButton.joinState = .joined
        } else {
            cell.joinButton.joinState = .join
            cell.joinButton.setTitle("Force Join", for: .normal)
        }

        return cell
    }
}

extension ForceJoinViewController: UISearchBarDelegate {

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
                $0.username.lowercased().contains(query) || $0.fullName.lowercased().contains(query)
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

extension ForceJoinViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if isSearching {
            return emptyStateSearch.title
        } else {
            return emptyStateMembers.title
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -scrollView.frame.height/5
    }
}

fileprivate struct Section {
    let letter : String
    let viewModels : [UserViewModel]
}
