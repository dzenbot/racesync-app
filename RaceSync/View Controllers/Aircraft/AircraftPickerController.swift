//
//  AircraftPickerController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-11.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import Presentr

class AircraftPickerController: UINavigationController {

    // MARK: - Public Variables

    var didSelect: SimpleObjectCompletionBlock<ObjectId>?
    var didError: VoidCompletionBlock?
    var didCancel: VoidCompletionBlock?

    // MARK: - Presentation

    static func showAircraftPicker(for race: Race) -> AircraftPickerController {

        let vc = AircraftPickerViewController(with: race)
        let aircraftPicker = AircraftPickerController(rootViewController: vc)
        let presenter = Appearance.defaultPresenter()

        let topVC = UIViewController.topMostViewController()
        topVC?.customPresentViewController(presenter, viewController: aircraftPicker, animated: true)

        vc.delegate = aircraftPicker
        
        return aircraftPicker
    }
}

extension AircraftPickerController: AircraftPickerViewControllerDelegate {

    func aircraftPickerViewController(_ viewController: AircraftPickerViewController, didSelectAircraft aircraftId: ObjectId) {
        didSelect?(aircraftId)
        dismiss(animated: true)
    }

    func aircraftPickerViewControllerDidError(_ viewController: AircraftPickerViewController) {
        didError?()
    }

    func aircraftPickerViewControllerDidDismiss(_ viewController: AircraftPickerViewController) {
        didCancel?()
        dismiss(animated: true)
    }
}

extension AircraftPickerController: PresentrDelegate {

    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        didCancel?()
        return true
    }
}
