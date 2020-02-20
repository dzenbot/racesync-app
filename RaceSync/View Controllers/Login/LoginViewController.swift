//
//  LoginViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-10-23.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import SnapKit
import SwiftValidators
import RaceSyncAPI

class LoginViewController: UIViewController {

    // MARK: - Private Variables

    fileprivate lazy var loginFormView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = Color.white
        view.addSubview(self.titleLabel)
        view.addSubview(self.emailField)
        view.addSubview(self.passwordField)
        view.addSubview(self.passwordRecoveryButton)
        view.addSubview(self.createAccountButton)
        view.addSubview(self.loginButton)
        view.addSubview(self.legalButton)
        return view
    }()

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = APIServices.shared.settings.isDev ? "Login with test.MultiGP" : "Login with MultiGP"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = Color.gray200
        return label
    }()

    fileprivate lazy var emailField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        textField.textContentType = .emailAddress
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()

    fileprivate lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Password"
        textField.keyboardType = .`default`
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .`continue`
        textField.textContentType = .password
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()

    fileprivate lazy var passwordRecoveryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(Color.red, for: .normal)
        button.setTitle("Forgot your password?", for: .normal)
        button.addTarget(self, action:#selector(didPressPasswordRecoveryButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(Color.red, for: .normal)
        button.setTitle("Create an account", for: .normal)
        button.addTarget(self, action:#selector(didPressCreateAccountButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var loginButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .regular)
        button.setTitleColor(Color.blue, for: .normal)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = Color.white
        button.layer.cornerRadius = Constants.padding/2
        button.layer.borderColor = Color.gray100.cgColor
        button.layer.borderWidth = 0.5
        button.addTarget(self, action:#selector(didPressLoginButton), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var legalButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action:#selector(didPressLegalButton), for: .touchUpInside)

        let link = "Terms of Use"
        let label = "By tapping “Login” you will accept our " + link + "."

        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                          NSAttributedString.Key.foregroundColor: Color.gray200]

        let linkAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                          NSAttributedString.Key.foregroundColor: Color.red]

        let attributedString = NSMutableAttributedString(string:label , attributes: attributes)
        attributedString.setAttributes(linkAttributes, range: NSString(string: label).range(of: link))
        button.setAttributedTitle(attributedString, for: .normal)

        return button
    }()

    @IBOutlet fileprivate weak var racesyncLogoView: UIImageView!
    @IBOutlet fileprivate weak var racesyncLogoViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var racesyncLogoViewOriginY: NSLayoutConstraint!

    @IBOutlet fileprivate weak var mgpLogoView: UIImageView!
    @IBOutlet fileprivate weak var mgpLogoLabel: UILabel!

    fileprivate var loginFormViewCenterYConstraint: Constraint?
    fileprivate var loginFormViewCenterYConstant: CGFloat = 0

    fileprivate var racesyncLogoHeightConstant: CGFloat = 0
    fileprivate var isKeyboardVisible: Bool = false

    fileprivate var authApi = AuthApi()
    fileprivate var shouldShowForm: Bool {
        get { return loginFormView.superview == nil }
    }

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let loginFormHeight: CGFloat = 320
        static let actionButtonHeight: CGFloat = 50
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        if !APIServices.shared.isLoggedIn {
            emailField.text = APIServices.shared.credential.email
            passwordField.text = APIServices.shared.credential.password
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shouldShowForm && !APIServices.shared.isLoggedIn {
            setupLayout()
        } else {
            // resetting API object, for when logging out
            authApi = AuthApi()
            titleLabel.text = APIServices.shared.settings.isDev ? "Login with test.MultiGP" : "Login with MultiGP"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Skip login if there's a persisted sessionId
        if APIServices.shared.isLoggedIn {
            presentHome()
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(250)) {
                self.emailField.becomeFirstResponder()
            }
        }
    }

    // MARK: - Layout

    func setupLayout() {

        view.insertSubview(loginFormView, belowSubview: racesyncLogoView)
        loginFormView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.height.greaterThanOrEqualTo(Constants.loginFormHeight)

            loginFormViewCenterYConstraint = $0.centerY.equalToSuperview().constraint
            loginFormViewCenterYConstraint?.activate()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }

        emailField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.padding*1.5)
            $0.leading.equalToSuperview().offset(Constants.padding/2)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        passwordField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(Constants.padding*2)
            $0.leading.equalToSuperview().offset(Constants.padding/2)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        func addline(under view: UIView) {
            let separatorLine = UIView()
            separatorLine.backgroundColor = Color.gray100
            loginFormView.addSubview(separatorLine)
            separatorLine.snp.makeConstraints {
                $0.top.equalTo(view.snp.bottom).offset(Constants.padding/2)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(0.5)
            }
        }

        addline(under: emailField)
        addline(under: passwordField)

        passwordRecoveryButton.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(Constants.padding*1.5)
            $0.leading.equalToSuperview()
        }

        createAccountButton.snp.makeConstraints {
            $0.top.equalTo(passwordRecoveryButton.snp.bottom).offset(Constants.padding/2)
            $0.leading.equalToSuperview()
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(createAccountButton.snp.bottom).offset(Constants.padding)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(Constants.actionButtonHeight)
        }

        legalButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(Constants.padding/2)
            $0.centerX.equalToSuperview()
        }
    }

    // MARK: - Button Events

    @objc func didPressPasswordRecoveryButton() {
        let url = MGPWeb.getURL(for: .passwordReset)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func didPressCreateAccountButton() {
        let url = MGPWeb.getURL(for: .accountRegistration)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func didPressLoginButton() {
        guard let email = emailField.text else { shakeLoginButton(); return }
        guard Validator.isEmail().apply(email) else { shakeLoginButton(); return }

        guard let password = passwordField.text else { shakeLoginButton(); return }
        guard !Validator.isEmpty().apply(password) else { shakeLoginButton(); return }

        // Invalidate the form momentairly
        freezeLoginForm()
        loginButton.isLoading = true

        // Login
        authApi.login(email, password: password) { [weak self] (error) in
            if let _ = error {
                // TODO: Handle errors. At least, display in screen.
                print("Login error \(error.debugDescription)!")
                self?.loginButton.isLoading = false
                self?.freezeLoginForm(false)
            } else {
                self?.presentHome(transition: .flipHorizontal)
            }
        }
    }

    @objc func didPressLegalButton() {
        let url = MGPWeb.getURL(for: .termsOfUse)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {

        guard !isKeyboardVisible else { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let keyboardRect = keyboardFrame.cgRectValue

        guard keyboardRect.intersects(loginFormView.frame) else { return }

        let intersection = keyboardRect.intersection(loginFormView.frame)

        loginFormViewCenterYConstant = intersection.height
        racesyncLogoHeightConstant = loginFormView.frame.minY - (intersection.height + Constants.padding*3)
        let racesyncLogoAlpha: CGFloat = 1

        UIView.animate(withDuration: animationDuration,
                       animations: {
                        self.loginFormViewCenterYConstraint?.update(offset: -self.loginFormViewCenterYConstant)
                        self.loginFormView.alpha = 1
                        self.view.layoutIfNeeded()
        },
                       completion: nil)

        guard racesyncLogoViewOriginY.constant != 0 else { return }

        UIView.animate(withDuration: animationDuration,
                       animations: {
                        self.racesyncLogoViewOriginY.constant = 0
                        self.racesyncLogoViewHeight.constant = self.racesyncLogoHeightConstant
                        self.racesyncLogoView.alpha = racesyncLogoAlpha
                        self.view.layoutIfNeeded()
        },
                       completion: nil)

        isKeyboardVisible = true
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard isKeyboardVisible else { return }
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let racesyncLogoViewOriginYConstant = loginFormViewCenterYConstant/2
        loginFormViewCenterYConstant = 0

        UIView.animate(withDuration: animationDuration,
                       animations: {
                        self.loginFormViewCenterYConstraint?.update(offset: 0)
                        self.racesyncLogoViewOriginY.constant = racesyncLogoViewOriginYConstant

                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
        },
                       completion: nil)

        isKeyboardVisible = false
    }

    // MARK: - Transitions

    func shakeLoginButton() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.4
        animation.values = [-20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        loginButton.layer.add(animation, forKey: "shake")
    }

    func freezeLoginForm(_ freeze: Bool = true) {
        emailField.isUserInteractionEnabled = !freeze
        passwordField.isUserInteractionEnabled = !freeze
        passwordRecoveryButton.isUserInteractionEnabled = !freeze
        createAccountButton.isUserInteractionEnabled = !freeze
        loginButton.isUserInteractionEnabled = !freeze
        legalButton.isUserInteractionEnabled = !freeze
    }

    func presentHome(transition: UIModalTransitionStyle = .crossDissolve) {
        let raceListVC = RaceListViewController(nibName: nil, bundle: nil)
        let raceListNC = NavigationController(rootViewController: raceListVC)
        raceListNC.modalTransitionStyle = transition
        raceListNC.modalPresentationStyle = .fullScreen

        present(raceListNC, animated: true) { [weak self] in
            self?.loginButton.isLoading = false
            self?.freezeLoginForm(false)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        //
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didPressLoginButton()
        }

        return true
    }
}
