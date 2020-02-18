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

class PickerViewController: UIViewController {

    override var title: String? {
        didSet {
            navigationBarItem.title = title
        }
    }

    // MARK: - Private Variables

    fileprivate lazy var navigationBar: UINavigationBar = {
        let view = UINavigationBar()
        view.barTintColor = Color.clear
        view.items = [navigationBarItem]
        return view
    }()

    fileprivate lazy var navigationBarItem: UINavigationItem = {
        let item = UINavigationItem()
        item.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        item.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didPressSaveButton))
        item.rightBarButtonItem?.isEnabled = false
        return item
    }()

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

    fileprivate let items: [String]
    fileprivate var selectedItem: String?

    // MARK: - Initialization

    init(with items: [String], selectedItem: String? = nil) {
        self.items = items
        self.selectedItem = selectedItem
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

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        view.addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }

        if let selectedItem = selectedItem, let index = items.firstIndex(of: selectedItem) {
            pickerView.selectRow(index, animated: false)
        }
    }

    // MARK: - Actions

    @objc func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didPressSaveButton() {
        print("didPressSaveButton")
    }
}

extension PickerViewController: PickerViewDataSource {

    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: PickerView, titleForRow row: Int) -> String {
        return items[row]
    }
}

extension PickerViewController: PickerViewDelegate {

    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 50
    }

    func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
        let item = items[row]
        print("The selected item is \(item)")

        navigationBarItem.rightBarButtonItem?.isEnabled = item != selectedItem
    }

    func pickerView(_ pickerView: PickerView, didTapRow row: Int) {
        print("The row \(row) was tapped by the user")
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
