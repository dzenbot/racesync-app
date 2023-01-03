//
//  DatePickerViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import SnapKit
import PickerView
import Presentr
import UIKit
import RaceSyncAPI

class DatePickerViewController: FormBaseViewController {

    // MARK: - Public Variables

    override var isLoading: Bool {
        get { return false }
        set { }
    }

    override var formType: FormType {
        get { return .datePicker }
        set { }
    }

    // MARK: - Private Variables

    fileprivate lazy var pickerView: UIDatePicker = {
        let view = UIDatePicker()

        if #available(iOS 13.4, *) {
            view.preferredDatePickerStyle = .wheels
        }

        view.minimumDate = Date()
        view.timeZone = NSTimeZone.local
        view.backgroundColor = Color.white
        view.datePickerMode = .dateAndTime
        view.minuteInterval = 15
        view.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return view
    }()

    fileprivate lazy var rightBarButtonItem: UIBarButtonItem = {
        let title = self.delegate?.formViewControllerRightBarButtonTitle?(self) ?? "OK"
        let barButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(didPressOKButton))
        return barButtonItem
    }()

    fileprivate var selectedDate: Date?

    // MARK: - Initialization

    init(with date: Date? = nil) {
        selectedDate = date

        super.init(nibName: nil, bundle: nil)
        self.pickerView.date = date ?? Date()
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

        view.backgroundColor = Color.white

        view.addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
        }

        configureButtonBarItems()
    }

    fileprivate func configureButtonBarItems() {
        if let nc = navigationController, nc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))
        }

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = delegate?.formViewController?(self, enableSelectionWithItem: selectedDateString() ?? "") ?? false
    }

    fileprivate func selectedDateString() -> String? {
        guard let date = selectedDate else { return nil }
        return DateUtil.isoDateFormatter.string(from: date)
    }

    // MARK: - Actions

    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        selectedDate = sender.date

        navigationItem.rightBarButtonItem?.isEnabled = delegate?.formViewController?(self, enableSelectionWithItem: selectedDateString() ?? "") ?? false
    }

    @objc func didPressCloseButton() {
        dismiss(animated: true)
        delegate?.formViewControllerDidDismiss(self)
    }

    @objc func didPressOKButton() {
        guard let item = selectedDateString() else { return }
        delegate?.formViewController(self, didSelectItem: item)
    }
}

