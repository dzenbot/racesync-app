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

    // MARK: - Private Variables

    let canAddAircraft: Bool = true

    lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: AircraftCollectionViewCell.height, height: AircraftCollectionViewCell.height)
        layout.minimumInteritemSpacing = Constants.padding
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.padding, bottom: 0, right: Constants.padding)
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout:collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AircraftCollectionViewCell.self, forCellWithReuseIdentifier: AircraftCollectionViewCell.identifier)
        collectionView.backgroundColor = Color.white
        collectionView.alwaysBounceVertical = true
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        return collectionView
    }()

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    var isLoading: Bool = false {
        didSet {
            if isLoading { activityIndicatorView.startAnimating() }
            else { activityIndicatorView.stopAnimating() }
        }
    }

    fileprivate let aircraftApi = AircraftAPI()
    fileprivate var aircraftViewModels = [AircraftViewModel]()

    fileprivate var emptyStateAircrafts = EmptyStateViewModel(.noAircrafts)

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        isLoading = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchMyAircrafts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    func setupLayout() {

        view.backgroundColor = Color.white
        navigationItem.title = "My Aircrafts"

        if canAddAircraft {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton))
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    // MARK: - Button Events

    @objc func didPressAddButton() {
        print("didPressAddButton")
    }
}

extension AircraftListViewController {

    func fetchMyAircrafts() {
        aircraftApi.getMyAircrafts() { [weak self] (aircrafts, error) in
            if let aircrafts = aircrafts {
                self?.aircraftViewModels = [AircraftViewModel]()
                self?.aircraftViewModels += AircraftViewModel.viewModels(with: aircrafts)
                self?.isLoading = false
                self?.collectionView.reloadData()
            } else if error != nil {
                print("fetchMyUser error : \(error.debugDescription)")
            }
        }
    }

    func deselectAllItems() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        for item in indexPaths {
            collectionView.deselectItem(at: item, animated: true)
        }
    }
}

extension AircraftListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = aircraftViewModels[indexPath.row]

        let aircraftDetailVC = AircraftDetailViewController(with: viewModel)
        aircraftDetailVC.delegate = self
        navigationController?.pushViewController(aircraftDetailVC, animated: true)

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

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AircraftCollectionViewCell.identifier, for: indexPath) as! AircraftCollectionViewCell

        let viewModel = aircraftViewModels[indexPath.row]
        cell.titleLabel.text = viewModel.displayName

        if viewModel.isGeneric {
            cell.avatarImageView.imageView.image = UIImage(named: "placeholder_large_aircraft_create")
        } else {
            cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: UIImage(named: "placeholder_large_aircraft"))
        }

        return cell
    }
}

extension AircraftListViewController: AircraftDetailViewControllerDelegate {

    func aircraftDetailViewController(_ viewController: AircraftDetailViewController, didDeleteAircraft aircraftId: ObjectId) {

        if let index = aircraftViewModels.firstIndex(where: { $0.aircraftId == aircraftId }) {
            aircraftViewModels.remove(at: index)
            collectionView.reloadData()
        }

        navigationController?.popViewController(animated: true)
    }
}

extension AircraftListViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyStateAircrafts.title
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyStateAircrafts.description
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return emptyStateAircrafts.buttonTitle(state)
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
        print("Add Aircraft!")
    }
}
