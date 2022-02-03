//
//  RaceMapViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import MapKit
import RaceSyncAPI

class MapViewController: UIViewController {

    var showsDirection: Bool = true {
        didSet {
            if showsDirection {
                navigationItem.rightBarButtonItem = navigationBarButtonItem
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }

    // MARK: - Private Variables

    fileprivate let coordinates: CLLocationCoordinate2D
    fileprivate let address: String

    fileprivate lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        return mapView
    }()

    fileprivate let initialSelectedMapSegment: MapSegment = .map

    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let items = [MapSegment.map.title, MapSegment.hybrid.title, MapSegment.satellite.title]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = initialSelectedMapSegment.rawValue
        segmentedControl.backgroundColor = Color.gray100.withAlphaComponent(0.5)
        return segmentedControl
    }()

    fileprivate lazy var navigationBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "icn_navbar_directions"), style: .done, target: self, action: #selector(didPressDirectionsButton))
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
        static let annotationIdentifier: String = "Annotation"
    }

    // MARK: - Initialization

    init(with coordinates: CLLocationCoordinate2D, address: String) {
        self.coordinates = coordinates
        self.address = address
        super.init(nibName: nil, bundle: nil)

        title = "Location"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadMapView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        if showsDirection {
            navigationItem.rightBarButtonItem = navigationBarButtonItem
        }

        navigationController?.isToolbarHidden = false

        if let toolbar = navigationController?.toolbar {
            toolbar.addSubview(segmentedControl)
            segmentedControl.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(Constants.padding*2)
                $0.trailing.equalToSuperview().offset(-Constants.padding*2)
            }
        }

        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    fileprivate func loadMapView() {

        let distance:Double = 1000
        let meters = CLLocationDistance(distance)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: meters, longitudinalMeters: meters)
        let mapRect = MKCoordinateRegion.mapRectForCoordinateRegion(region)
        let paddedMapRect = mapRect.offsetBy(dx: 0, dy: -(distance*2)) // TODO: Convert Screen points to Map points instead of harcoded value

        mapView.setVisibleMapRect(paddedMapRect, animated: false)

        let location = MKPointAnnotation()
        location.title = address
        location.coordinate = coordinates
        mapView.addAnnotation(location)
    }

    // MARK: - Actions

    @objc func didPressDirectionsButton() {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = Color.blue
        
        alert.addAction(UIAlertAction(title: "Open in Maps", style: .default, handler: { [weak self] (action) in
            guard let lat = self?.coordinates.latitude, let long = self?.coordinates.longitude else { return }
            guard let url = URL(string: "\(ExternalAppConstants.AppleMapsUrl)?daddr=\(lat),\(long)&dirflg=d") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))

        if canOpenGoogleMaps {
            alert.addAction(UIAlertAction(title: "Open in Google Maps", style: .default, handler: { [weak self] (action) in
                guard let lat = self?.coordinates.latitude, let long = self?.coordinates.longitude else { return }
                guard let url = URL(string: "\(ExternalAppConstants.GoogleMapsScheme)?daddr=\(lat),\(long)") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }

        if canOpenWaze {
            alert.addAction(UIAlertAction(title: "Open in Waze", style: .default, handler: { [weak self] (action) in
                guard let lat = self?.coordinates.latitude, let long = self?.coordinates.longitude else { return }
                guard let url = URL(string: "\(ExternalAppConstants.WazeScheme)?ll=\(lat),\(long)&navigate=yes") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }

        alert.addAction(UIAlertAction(title: "Copy Coordinates", style: .default, handler: { [weak self] (action) in
            guard let lat = self?.coordinates.latitude, let long = self?.coordinates.longitude else { return }
            UIPasteboard.general.string = "\(lat), \(long)"
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    @objc func didPressCloseButton() {
        dismiss(animated: true)
    }

    @objc fileprivate func didChangeSegment() {
        guard let segment = MapSegment(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        mapView.mapType = segment.mapType
    }


    // MARK: - Integration

    fileprivate var canOpenGoogleMaps: Bool {
        guard let url = URL(string: ExternalAppConstants.GoogleMapsScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    fileprivate var canOpenWaze: Bool {
        guard let url = URL(string: ExternalAppConstants.WazeScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationIdentifier)

        if let view = annotationView {
            view.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.annotationIdentifier)
            annotationView?.image = UIImage(named: "icn_map_annotation")
            annotationView?.canShowCallout = true
        }

        return annotationView
    }

}

fileprivate enum MapSegment: Int {
    case map, hybrid, satellite

    var title: String {
        switch self {
        case .map:          return "Map"
        case .hybrid:       return "Hybrid"
        case .satellite:    return "Satellite"
        }
    }

    var mapType: MKMapType {
        switch self {
        case .map:          return .standard
        case .hybrid:       return .hybrid
        case .satellite:    return .satellite
        }
    }
}
