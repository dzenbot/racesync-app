//
//  SettingsController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-07.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import Presentr

class SettingsController {

    // MARK: - Public Variables

    var completion: VoidCompletionBlock?
    var settingsType: APISettingsType?

    // MARK: - Presentation

    func presentSettingsPicker(_ type: APISettingsType, from presentingVC: UIViewController, completion: VoidCompletionBlock?) {
        self.settingsType = type
        self.completion = completion

        switch type {
        case .searchRadius:
            presentSearchRadiusPicker(from: presentingVC)
        case .measurement:
            presentMeasurementUnitPicker(from: presentingVC)
        default:
            return
        }
    }

    fileprivate func presentSearchRadiusPicker(from presentingVC: UIViewController) {
        let settings = APIServices.shared.settings
        let items = settings.lengthUnit.supportedValues
        let selectedItem = settings.searchRadius

        let presenter = Appearance.defaultPresenter()
        let pickerVC = PickerViewController(with: items, selectedItem: selectedItem)
        pickerVC.delegate = self
        pickerVC.title = settingsType?.title
        pickerVC.unit = settings.lengthUnit.symbol

        let pickerVN = NavigationController(rootViewController: pickerVC)
        presentingVC.customPresentViewController(presenter, viewController: pickerVN, animated: true)
    }

    fileprivate func presentMeasurementUnitPicker(from presentingVC: UIViewController) {
        let settings = APIServices.shared.settings
        let values = APIMeasurementSystem.allCases.compactMap { $0.title }
        let selectedItem = settings.measurementSystem.title

        let presenter = Appearance.defaultPresenter()
        let pickerVC = PickerViewController(with: values, selectedItem: selectedItem)
        pickerVC.delegate = self
        pickerVC.title = settingsType?.title

        let pickerVN = NavigationController(rootViewController: pickerVC)
        presentingVC.customPresentViewController(presenter, viewController: pickerVN, animated: true)
    }
}

extension SettingsController: FormBaseViewControllerDelegate {

    func formViewController(_ viewController: FormBaseViewController, didSelectItem item: String) {

        let settings = APIServices.shared.settings

        if settingsType == .searchRadius {
            settings.searchRadius = item
        } else if settingsType == .measurement, let system = APIMeasurementSystem(title: item) {

            let previousUnit = settings.lengthUnit
            settings.measurementSystem = system
            let newUnit = settings.lengthUnit

            // To make values compatible, we user similar lenghts instead of converting and having values with decimals
            if let idx = previousUnit.supportedValues.firstIndex(of: settings.searchRadius) {
                let value = newUnit.supportedValues[idx]
                settings.update(searchRadius: value)
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.completion?()
        }

        viewController.dismiss(animated: true)
    }

    func formViewControllerDidDismiss(_ viewController: FormBaseViewController) {
        // invalidate variables after we dismiss
        completion = nil
        settingsType = nil
    }
}
