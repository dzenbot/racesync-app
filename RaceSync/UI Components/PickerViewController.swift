//
//  PickerViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-18.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import PickerView
import Presentr

class PickerViewController: FormViewController {

    // MARK: - Public Variables

    override var isLoading: Bool {
        didSet {
            if isLoading {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            else {
                navigationItem.rightBarButtonItem = rightBarButtonItem
                activityIndicatorView.stopAnimating()
            }
        }
    }

    override var formType: FormType {
        get { return .picker }
        set { }
    }

    var unit: String?

    // MARK: - Private Variables

    fileprivate lazy var pickerView: PickerView = {
        let view = PickerView()
        view.tableView.contentInsetAdjustmentBehavior = .never
        view.tintColor = Color.blue
        view.backgroundColor = Color.white
        view.selectionStyle = .defaultIndicator
        view.dataSource = self
        view.delegate = self
        return view
    }()

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    fileprivate lazy var rightBarButtonItem: UIBarButtonItem = {
        let title = self.delegate?.formViewControllerRightBarButtonTitle?(self) ?? "OK"
        let barButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(didPressOKButton))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()

    fileprivate let items: [String]
    fileprivate var selectedItem: String?
    fileprivate var defaultItem: String?

    // MARK: - Initialization

    init(with items: [String], selectedItem: String? = nil, defaultItem: String? = nil) {
        self.items = items
        self.selectedItem = selectedItem
        self.defaultItem = defaultItem
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

    func setupLayout() {

        view.backgroundColor = Color.white

        if let nc = navigationController, nc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        }

        navigationItem.rightBarButtonItem = rightBarButtonItem

        view.addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
        }

        if let selectedItem = selectedItem, let index = items.firstIndex(of: selectedItem) {
            pickerView.selectRow(index, animated: false)
        } else if let defaultItem = defaultItem, let index = items.firstIndex(of: defaultItem) {
            pickerView.selectRow(index, animated: false)
        }
    }

    // MARK: - Actions

    @objc func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
        delegate?.formViewControllerDidDismiss(self)
    }

    @objc func didPressOKButton() {
        let item = items[pickerView.currentSelectedRow]
        delegate?.formViewController(self, didSelectItem: item)
    }
}

extension PickerViewController: PickerViewDataSource {

    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: PickerView, titleForRow row: Int) -> String {
        var title = items[row]
        if let unit = unit {
            title += " \(unit)"
        }
        return title
    }
}

extension PickerViewController: PickerViewDelegate {

    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 50
    }

    func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
        let item = items[row]

        navigationItem.rightBarButtonItem?.isEnabled = item != selectedItem
    }

    func pickerView(_ pickerView: PickerView, didTapRow row: Int) {
        // 
    }

    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        label.textAlignment = .center

        if highlighted {
            label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
            label.textColor = Color.blue
        } else {
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.textColor = Color.gray200
        }
    }
}

extension PickerViewController: PresentrDelegate {

    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        DispatchQueue.main.async {
            self.delegate?.formViewControllerDidDismiss(self)
        }

        return true
    }
}
