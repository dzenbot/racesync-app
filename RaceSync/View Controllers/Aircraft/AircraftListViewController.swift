//
//  AircraftListViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-17.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import EmptyDataSet_Swift

class AircraftListViewController: UIViewController {

    // MARK: - Public Variables

    var isEditable: Bool = true

    // MARK: - Private Variables

    fileprivate lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: AircraftCollectionViewCell.height, height: AircraftCollectionViewCell.height)
        layout.minimumInteritemSpacing = Constants.padding
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.padding, bottom: 0, right: Constants.padding)
        return layout
    }()

    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout:collectionViewLayout)
        collectionView.register(cellType: AircraftCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Color.white
        collectionView.alwaysBounceVertical = true
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        return collectionView
    }()

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .large)
    }()

    fileprivate var isLoading: Bool = false {
        didSet {
            if isLoading { activityIndicatorView.startAnimating() }
            else { activityIndicatorView.stopAnimating() }
        }
    }

    fileprivate let user: User
    fileprivate let aircraftApi = AircraftApi()
    fileprivate var aircraftViewModels = [AircraftViewModel]()
    fileprivate var shouldReloadAircraft: Bool = true

    fileprivate var emptyStateAircraft = EmptyStateViewModel(.noAircraft)
    fileprivate var emptyStateMyAircraft = EmptyStateViewModel(.noMyAircraft)
    fileprivate var emptyStateError: EmptyStateViewModel?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Initialization

    init(with user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        // only show the spinner once
        isLoading = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchAircraft()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = user.isMe ? "My Aircraft" : "Aircraft"
        view.backgroundColor = Color.white

        if isEditable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: ButtonImg.add, style: .done, target: self, action: #selector(didPressCreateButton))
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc func didPressCreateButton() {
        let vc = NewAircraftViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AircraftListViewController {

    func fetchAircraft() {
        guard shouldReloadAircraft else { return }

        aircraftApi.getAircraft(forUser: user.id) { [weak self] (aircraft, error) in

            if let aircraft = aircraft {
                let viewModels = AircraftViewModel.viewModels(with: aircraft)

                self?.aircraftViewModels = [AircraftViewModel]()
                self?.aircraftViewModels += viewModels.sorted(by: { (c1, c2) -> Bool in
                    return c1.displayName.lowercased() < c2.displayName.lowercased()
                })
                self?.isLoading = false
                self?.collectionView.reloadData()
            } else if let error = error {
                self?.handleError(error)
            }
        }

        shouldReloadAircraft = false
    }

    func showAircraftDetail(_ aircraftViewModel: AircraftViewModel, isNew: Bool = false, animated: Bool = true) {
        let vc = AircraftDetailViewController(with: aircraftViewModel)
        vc.delegate = self
        vc.isEditable = isEditable
        vc.isNew = isNew
        navigationController?.pushViewController(vc, animated: animated)
    }

    func deleteAircraft(_ viewModel: AircraftViewModel) {
        let aircraftId = viewModel.aircraftId

        aircraftApi.retire(aircraft: aircraftId) { [weak self] (status, error)  in
            if status {
                self?.removeAircraft(withId: aircraftId)
            } else if let error = error {
                AlertUtil.presentAlertMessage(error.localizedDescription, title: "Error")
            }
        }
    }

    func removeAircraft(withId id: ObjectId) {
        guard let row = aircraftViewModels.firstIndex(where: { $0.aircraftId == id }) else { return }

        let indexPath = IndexPath(row: row, section: 0)
        aircraftViewModels.remove(at: row)

        collectionView.performBatchUpdates({
        collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
    }

    func deselectAllItems() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        for item in indexPaths {
            collectionView.deselectItem(at: item, animated: true)
        }
    }

    // MARK: - Error

    fileprivate func handleError(_ error: Error) {
        emptyStateError = EmptyStateViewModel(.errorAircraft)
        collectionView.reloadEmptyDataSet()
    }
}

extension AircraftListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = aircraftViewModels[indexPath.row]

        showAircraftDetail(viewModel)
        collectionView.deselectAllItems()
    }
}

extension AircraftListViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aircraftViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as AircraftCollectionViewCell
        let viewModel = aircraftViewModels[indexPath.row]
        cell.titleLabel.text = viewModel.displayName
        cell.delegate = self

        if viewModel.isGeneric {
            cell.avatarImageView.imageView.image = PlaceholderImg.largeNewAircraft
        } else {
            cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: PlaceholderImg.largeAircraft)
        }

        return cell
    }
}

extension AircraftListViewController: AircraftCollectionViewCellDelegate {

    func aircraftCollectionViewCellDidLongPress(_ cell: AircraftCollectionViewCell, at point: CGPoint) {
        let newPoint = cell.convert(point, to: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: newPoint) else { return }

        let aircraftViewModel = aircraftViewModels[indexPath.row]
        ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to delete \"\(aircraftViewModel.displayName)\"?", destructiveTitle: "Yes, delete", completion: { (action) in
            self.deleteAircraft(aircraftViewModel)
        }, cancel: nil)
    }
}

extension AircraftListViewController: AircraftDetailViewControllerDelegate {

    func aircraftDetailViewController(_ viewController: AircraftDetailViewController, didEditAircraft aircraftId: ObjectId) {
        shouldReloadAircraft = true
    }

    func aircraftDetailViewController(_ viewController: AircraftDetailViewController, didDeleteAircraft aircraftId: ObjectId) {
        removeAircraft(withId: aircraftId)
        navigationController?.popViewController(animated: true)
    }
}

extension AircraftListViewController: NewAircraftViewControllerDelegate {

    func newAircraftViewController(_ viewController: NewAircraftViewController, didCreateAircraft aircraft: Aircraft) {

        let newViewModel = AircraftViewModel(with: aircraft)

        // Swap view controller without animation, so the user can now upload an image to the new aircraft
        // TODO: The aircraft spec list doesn't show entirely. It is covered by the header for whatever reason.
        navigationController?.popViewController(animated: false)
        showAircraftDetail(newViewModel, isNew: true, animated: false)
    }

    func newAircraftViewControllerDidDismiss(_ viewController: NewAircraftViewController) {
        //
    }

    func newAircraftViewController(_ viewController: NewAircraftViewController, valuesFor row: AircraftRow) -> [String]? {
        return nil
    }
}

extension AircraftListViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if emptyStateError != nil {
            return emptyStateError?.title
        } else if isEditable {
            return emptyStateMyAircraft.title
        } else {
            return emptyStateAircraft.title
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if emptyStateError != nil {
            return emptyStateError?.description
        } else if isEditable {
            return emptyStateMyAircraft.description
        } else {
            return emptyStateAircraft.description
        }
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        if emptyStateError != nil {
            return emptyStateError?.buttonTitle(state)
        } else if isEditable {
            return emptyStateMyAircraft.buttonTitle(state)
        } else {
            return emptyStateAircraft.buttonTitle(state)
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -(navigationController?.navigationBar.frame.height ?? 0)
    }
}

extension AircraftListViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return !isLoading
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {

        if emptyStateError != nil {
            guard let url = MGPWeb.getPrefilledFeedbackFormUrl() else { return }
            WebViewController.openUrl(url)
        } else {
            didPressCreateButton()
        }
    }
}
