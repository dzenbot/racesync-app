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

    // MARK: - Private Variables


    // MARK: - Presentation

    static func showAircraftPicker(for race: Race) -> AircraftPickerController {

        let aircraftVC = AircraftListViewController(with: race)
        let aircraftPicker = AircraftPickerController(rootViewController: aircraftVC)

        let presenter = Presentr(presentationType: .bottomHalf)
        presenter.blurBackground = false
        presenter.backgroundOpacity = 0.2
        presenter.transitionType = .coverVertical
        presenter.dismissTransitionType = .coverVertical
        presenter.dismissAnimated = true
        presenter.dismissOnSwipe = true
        presenter.backgroundTap = .dismiss
        presenter.outsideContextTap = .passthrough
        presenter.roundCorners = true
        presenter.cornerRadius = 10
        
        let topVC = UIViewController.topMostViewController()
        topVC?.customPresentViewController(presenter, viewController: aircraftPicker, animated: true)

        aircraftVC.delegate = aircraftPicker
        return aircraftPicker
    }
}

extension AircraftPickerController: AircraftListViewControllerDelegate {

    func aircraftListViewController(_ viewController: AircraftListViewController, didSelectAircraft aircraftId: ObjectId) {
        didSelect?(aircraftId)
        dismiss(animated: true, completion: nil)
    }

    func aircraftListViewControllerDidError(_ viewController: AircraftListViewController) {
        didError?()
    }

    func aircraftListViewControllerDidDismiss(_ viewController: AircraftListViewController) {
        didCancel?()
        dismiss(animated: true, completion: nil)
    }
}

extension AircraftPickerController: PresentrDelegate {

    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        didCancel?()
        return true
    }

}
