//
//  AircraftPickerViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-08.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

protocol AircraftPickerViewControllerDelegate {
    func aircraftPickerViewController(_ viewController: AircraftPickerViewController, didSelectAircraft aircraftId: ObjectId)
    func aircraftPickerViewControllerDidError(_ viewController: AircraftPickerViewController)
    func aircraftPickerViewControllerDidDismiss(_ viewController: AircraftPickerViewController)
}

class AircraftPickerViewController: UIViewController {

    // MARK: - Public Variables

    var delegate: AircraftPickerViewControllerDelegate?

    // MARK: - Private Variables

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
        return collectionView
    }()

    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    fileprivate let race: Race
    fileprivate let aircraftApi = AircraftAPI()
    fileprivate var aircraftViewModels = [AircraftViewModel]()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let margin: UIEdgeInsets = UIEdgeInsets(proportionally: Constants.padding)
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
        fetchMyAircrafts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    func setupLayout() {

        view.backgroundColor = Color.white

        navigationItem.title = "Select Your Aircraft"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc func didPressCloseButton() {
        delegate?.aircraftPickerViewControllerDidDismiss(self)
    }
}

extension AircraftPickerViewController {

    func isLoading(_ loading: Bool) {
        collectionView.reloadData()
    }

    func fetchMyAircrafts() {
        isLoading(true)

        let specs = AircraftRaceSpecs(with: race)
        aircraftApi.getMyAircrafts(forRaceSpecs: specs) { [weak self] (aircrafts, error) in
            if let aircrafts = aircrafts {
                self?.aircraftViewModels += AircraftViewModel.viewModels(with: aircrafts)
                self?.aircraftViewModels += [AircraftViewModel(genericWith: "Generic Aircraft")]
                self?.isLoading(false)
            } else if error != nil {
                print("fetchMyUser error : \(error.debugDescription)")
            }
        }
    }

    func isWaiting(_ waiting: Bool, generic: Bool = false) {

        if waiting {
            activityIndicatorView.startAnimating()
            collectionView.deselectAllItems()
            collectionView.isUserInteractionEnabled = false
            collectionView.alpha = 0.5

            if generic {
                title = "Creating Generic Aircraft..."
            } else {
                title = "Joining Race..."
            }
        } else {
            activityIndicatorView.stopAnimating()
            collectionView.isUserInteractionEnabled = true
            collectionView.alpha = 1
            title = "Select Your Aircraft"
        }
    }
}

extension AircraftPickerViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let viewModel = aircraftViewModels[indexPath.row]

        let buttonTitle = "Yes, Join Race"
        var sheetTitle = ""

        if viewModel.isGeneric {
            sheetTitle = "Create a generic aircraft and join the race?"
        } else {
            sheetTitle = "Join the race with \(viewModel.displayName)?"
        }

        ActionSheetUtil.presentActionSheet(withTitle: sheetTitle, buttonTitle: buttonTitle, completion: { [weak self] (action) in
            self?.isWaiting(true, generic: viewModel.isGeneric)

            if let strongSelf = self {
                if viewModel.isGeneric {
                    let aircraftSpecs = AircraftSpecs(with: strongSelf.race)
                    strongSelf.aircraftApi.createAircraft(with: aircraftSpecs) { (aircraft, error) in
                        if let aircraft = aircraft {
                            strongSelf.delegate?.aircraftPickerViewController(strongSelf, didSelectAircraft: aircraft.id)
                        } else {
                            strongSelf.delegate?.aircraftPickerViewControllerDidError(strongSelf)
                            strongSelf.isWaiting(false)
                        }
                    }
                } else {
                    let viewModel = strongSelf.aircraftViewModels[indexPath.row]
                    strongSelf.delegate?.aircraftPickerViewController(strongSelf, didSelectAircraft: viewModel.aircraftId)
                }
            }

        }) { [weak self] (cancel) in
            self?.collectionView.deselectAllItems()
        }
    }
}

extension AircraftPickerViewController: UICollectionViewDataSource {

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
