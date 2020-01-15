//
//  RaceMapViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import MapKit

class RaceMapViewController: UIViewController {

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

    fileprivate lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        button.setImage(UIImage(named: "icn_navbar_close"), for: .normal)
        return button
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Initialization

    init(with coordinates: CLLocationCoordinate2D, address: String) {
        self.coordinates = coordinates
        self.address = address
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

        title = "Race Location"

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_share"), style: .done, target: self, action: #selector(didPressShareButton))

        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        loadMapView()
    }

    fileprivate func loadMapView() {
        let distance = CLLocationDistance(1000)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: distance, longitudinalMeters: distance)
        let mapRect = MKCoordinateRegion.mapRectForCoordinateRegion(region)
        let paddedMapRect = mapRect.offsetBy(dx: 0, dy: -1500) // TODO: Convert Screen points to Map points instead of harcoded value

        mapView.setVisibleMapRect(paddedMapRect, animated: false)

        let location = MKPointAnnotation()
        location.title = address
        location.coordinate = coordinates
        mapView.addAnnotation(location)
    }

    // MARK: - Actions

    @objc func didPressShareButton() {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Open in Maps", style: .default, handler: { (action) in
            let lat = self.coordinates.latitude
            let long = self.coordinates.longitude
            guard let url = URL(string: "\(WebUrls.appleMapsUrl)?daddr=\(lat),\(long)&dirflg=d") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))

        if canOpenGoogleMaps {
            alert.addAction(UIAlertAction(title: "Open in Google Maps", style: .default, handler: { (action) in
                let lat = self.coordinates.latitude
                let long = self.coordinates.longitude
                guard let url = URL(string: "\(WebUrls.googleMapsScheme)?daddr=\(lat),\(long)") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }

        if canOpenWaze {
            alert.addAction(UIAlertAction(title: "Open in Waze", style: .default, handler: { (action) in
                let lat = self.coordinates.latitude
                let long = self.coordinates.longitude
                guard let url = URL(string: "\(WebUrls.wazeScheme)?ll=\(lat),\(long)&navigate=yes") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    @objc func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Integration

    fileprivate var canOpenGoogleMaps: Bool {
        guard let url = URL(string: WebUrls.googleMapsScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    fileprivate var canOpenWaze: Bool {
        guard let url = URL(string: WebUrls.wazeScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

extension RaceMapViewController: MKMapViewDelegate {

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
