//
//  TrackListViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-11-30.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import SwiftyJSON
import EmptyDataSet_Swift

class TrackListViewController: UIViewController {

    // MARK: - Private Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(cellType: SimpleTableViewCell.self)
        tableView.emptyDataSetSource = self
        tableView.tableHeaderView = self.searchBar

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray20
        tableView.backgroundView = backgroundView

        return tableView
    }()

    lazy var searchBar: UISearchBar = {
        let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 56)
        let frame = CGRect(origin: .zero, size: size)

        let searchBar = UISearchBar(frame: frame)
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.barTintColor = .white
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()

    fileprivate var sections = [Section]()
    fileprivate var searchResult = [TrackViewModel]()
    fileprivate var trackViewModels = [TrackViewModel]()

    fileprivate var emptyStateSearch = EmptyStateViewModel(.noSearchResults)

    fileprivate var isSearching: Bool {
        guard let text = searchBar.text else { return false }
        return !text.isEmpty
    }

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTracks()
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
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

fileprivate extension TrackListViewController {

    func loadTracks() {

        func getSection(for type: TrackType) -> Section {
            let viewModels = TrackLoader.getTrackViewModels(with: type)
            return Section(title: type.title, viewModels: viewModels)
        }
        
        sections += [getSection(for: .gq)]
        sections += [getSection(for: .utt)]
        sections += [getSection(for: .champs)]
        sections += [getSection(for: .canada)]

        // used for search
        trackViewModels = sections.compactMap { $0.viewModels }.flatMap( { $0 })
    }

    func trackViewModel(at indexPath: IndexPath) -> TrackViewModel {
        if isSearching {
            return searchResult[indexPath.row]
        } else {
            let section = sections[indexPath.section]
            return section.viewModels[indexPath.row]
        }
    }
}

extension TrackListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewModel = trackViewModel(at: indexPath)
        let vc = TrackDetailViewController(with: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TrackListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching { return 1 }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isSearching else { return searchResult.count }
        return sections[section].viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return trackTableViewCell(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversalConstants.cellHeight
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isSearching else { return nil }
        return sections[section].title
    }

    func trackTableViewCell(for indexPath: IndexPath) -> SimpleTableViewCell {
        let viewModel = trackViewModel(at: indexPath)
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as SimpleTableViewCell
        cell.iconImageView.image = UIImage(named: "track_thumb_\(viewModel.track.id)")
        cell.titleLabel.text = viewModel.titleLabel
        cell.subtitleLabel.text = viewModel.subtitleLabel
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension TrackListViewController: UISearchBarDelegate {

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
        let keywords = searchText.lowercasedWords().filter({ $0 != ""})

        if !keywords.isEmpty {
            searchResult = trackViewModels.filter({
                let words = $0.titleLabel.lowercasedWords()
                var arr = [String]()

                for keyword in keywords {
                    for word in words {
                        if word.hasPrefix(keyword) {
                            arr.append(keyword)
                        }
                    }
                }
                return arr.count == keywords.count // matching words
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

extension TrackListViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if isSearching {
            return emptyStateSearch.title
        } else {
            return nil
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -scrollView.frame.height/10
    }
}

fileprivate struct Section {
    let title : String
    let viewModels : [TrackViewModel]
}
