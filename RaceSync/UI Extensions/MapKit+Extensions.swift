//
//  MapKit+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-18.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {

    static func mapRectForCoordinateRegion(_ region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)

        let point = MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y))
        let size = MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y))

        return MKMapRect(origin: point, size: size)
    }
}
