//
//  ChapterPickerViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-26.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RaceSyncAPI
import ShimmerSwift

protocol ChapterPickerViewControllerDelegate {
    func pickerController(_ viewController: ChapterPickerViewController, didPickChapter chapter: Chapter)
}

class ChapterPickerViewController: UIViewController, Shimmable {

    // MARK: - Public Variables

    var delegate: ChapterPickerViewControllerDelegate?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cellType: ChapterTableViewCell.self)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.white
        tableView.backgroundView = backgroundView

        return tableView
    }()

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                tableView.isUserInteractionEnabled = false
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            else {
                tableView.isUserInteractionEnabled = true
                navigationItem.rightBarButtonItem = rightBarButtonItem
                activityIndicatorView.stopAnimating()
            }
        }
    }

    var shimmeringView: ShimmeringView = defaultShimmeringView()

    // MARK: - Private Variables

    fileprivate lazy var rightBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didPressSaveButton))
        item.isEnabled = canSave()
        return item
    }()

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()

    func canSave() -> Bool {
        guard let myChapter = APIServices.shared.myChapter else { return false }
        guard let chapterId = selectedChapterId else { return false }
        return (myChapter.id != chapterId)
    }

    fileprivate let chapterApi = ChapterApi()
    fileprivate var chapterViewModels = [ChapterViewModel]()

    fileprivate var selectedChapterId: ObjectId? = APIServices.shared.myChapter?.id

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let avatarImageSize = CGSize(width: 50, height: 50)
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadChapters()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        view.backgroundColor = Color.white

        // Adds a close button in case of being presented modally
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))
        }
        navigationItem.rightBarButtonItem = rightBarButtonItem

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

    @objc fileprivate func didPressSaveButton() {
        guard let chapterId = selectedChapterId else { return }
        guard let chapter = chapterViewModels.chapter(withId: chapterId) else { return }

        delegate?.pickerController(self, didPickChapter: chapter)
    }

    @objc fileprivate func didPressCloseButton() {
        dismiss(animated: true)
    }

    // MARK: - Chapters

    func loadChapters() {
        if chapterViewModels.isEmpty {
            isLoadingList(true)

            fetchChapters { [weak self] in
                self?.isLoadingList(false)

                if let chapterId = self?.selectedChapterId {
                    self?.scrollToChapter(with: chapterId, animated: false)
                }
            }
        } else {
            tableView.reloadData()
        }
    }

    func fetchChapters(_ completion: VoidCompletionBlock? = nil) {
        guard let myUser = APIServices.shared.myUser else { return }

        chapterApi.getChapters(forUser: myUser.id) { [weak self] (chapters, error) in
            guard let s = self else { return }

            if let chapters = chapters {
                let chapterViewModels = ChapterViewModel.viewModels(with: chapters)

                s.chapterViewModels = chapterViewModels.sorted(by: { (c1, c2) -> Bool in
                    return c1.titleLabel.lowercased() < c2.titleLabel.lowercased()
                })
            } else {
                Clog.log("getChapters error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    func scrollToChapter(with chapterId: ObjectId, animated: Bool) {
        guard let row = chapterViewModels.firstIndex(where: { $0.chapter.id == chapterId }) else { return }

        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
}

extension ChapterPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewModel = chapterViewModels[indexPath.row]

        selectedChapterId = viewModel.chapter.id
        navigationItem.rightBarButtonItem?.isEnabled = canSave()

        tableView.reloadData()
    }
}

extension ChapterPickerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return chapterTableViewCell(for: indexPath)
    }

    func chapterTableViewCell(for indexPath: IndexPath) -> ChapterTableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as ChapterTableViewCell
        let viewModel = chapterViewModels[indexPath.row]

        cell.titleLabel.text = viewModel.titleLabel
        cell.subtitleLabel.text = viewModel.locationLabel
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: PlaceholderImg.medium, size: Constants.avatarImageSize)
        cell.accessoryType = .none

        if let selectedId = selectedChapterId {
            if viewModel.chapter.id == selectedId {
                let imageView = UIImageView(image: UIImage(named: "icn_cell_checkmark"))
                imageView.tintColor = Color.blue
                cell.accessoryView = imageView
            } else {
                cell.accessoryView = nil
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversalConstants.cellHeight
    }
}
