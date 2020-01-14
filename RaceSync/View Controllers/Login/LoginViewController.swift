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

    // MARK: - Feature Flags
    
    fileprivate var shouldAnimateIntro: Bool = true
    fileprivate var shouldPrefillTextFields: Bool = true
    fileprivate var shouldOpenKeyboardOnIntro: Bool = true

    // MARK: - Private Variables

    @IBOutlet weak var racesyncLogoView: UIImageView!
    @IBOutlet weak var racesyncLogoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var racesyncLogoViewOriginY: NSLayoutConstraint!

    @IBOutlet weak var mgpLogoView: UIImageView!
    @IBOutlet weak var mgpLogoLabel: UILabel!

    fileprivate let authApi = AuthApi()
    fileprivate var shouldShowForm: Bool {
        get { return loginFormView.superview == nil }
    }

    // MARK: - Lazy Variables

    lazy var loginFormView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .white
        view.addSubview(self.titleLabel)
        view.addSubview(self.emailField)
        view.addSubview(self.passwordField)
        view.addSubview(self.passwordRecoveryButton)
        view.addSubview(self.createAccountButton)
        view.addSubview(self.loginButton)
        view.addSubview(self.legalButton)
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = APIServices.shared.isDev ? "Login with MultiGP (test)" : "Login with MultiGP"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = Color.gray200
        return label
    }()

    lazy var emailField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Email"
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        return textField
    }()

    lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Password"
        textField.textContentType = .password
        textField.keyboardType = .`default`
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .`continue`
        return textField
    }()

    lazy var passwordRecoveryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(Color.red, for: .normal)
        button.setTitle("Forgot your password?", for: .normal)
        button.addTarget(self, action:#selector(didPressPasswordRecoveryButton), for: .touchUpInside)
        return button
    }()

    lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(Color.red, for: .normal)
        button.setTitle("Create an account", for: .normal)
        button.addTarget(self, action:#selector(didPressCreateAccountButton), for: .touchUpInside)
        return button
    }()

    lazy var loginButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle("LOGIN", for: .normal)
        button.backgroundColor = Color.blue
        button.layer.cornerRadius = Constants.padding/2
        button.addTarget(self, action:#selector(didPressLoginButton), for: .touchUpInside)
        return button
    }()

    lazy var legalButton: UIButton = {
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

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let loginButtonHeight: CGFloat = 50
        static let racesyncLogoHeightDecrement: CGFloat = 20
        static let racesyncLogoOriginYDecrement: CGFloat = 290
        static let formOriginYDecrement: CGFloat = 70
    }

    // MARK: - Initialization


    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shouldShowForm && !APIServices.shared.hasValidSession {
            setupLayout()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Skip login if there's a persisted sessionId
        if !APIServices.shared.hasValidSession {
            if shouldPrefillTextFields {
                emailField.text = APIServices.shared.environment.username
                passwordField.text = APIServices.shared.environment.password
            }
            animateIntro(duration: shouldAnimateIntro ? 0.7 : 0)
        } else {
            presentHome()
        }
    }

    // MARK: - Layout

    func setupLayout() {

        view.insertSubview(loginFormView, belowSubview: racesyncLogoView)
        loginFormView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.height.greaterThanOrEqualTo(360)
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
            $0.height.equalTo(Constants.loginButtonHeight)
        }

        legalButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(Constants.padding/2)
            $0.centerX.equalToSuperview()
        }
    }

    func animateIntro(duration: TimeInterval = 0.7) {

        // Animate the Racesync logo to the top
        UIView.animate(withDuration: duration,
                       delay: 0.2,
                       options: [.curveEaseInOut],
                       animations: {

                        self.racesyncLogoViewHeight.constant -= Constants.racesyncLogoHeightDecrement
                        self.racesyncLogoViewOriginY.constant -= Constants.racesyncLogoOriginYDecrement

                        self.loginFormView.snp.updateConstraints({
                            $0.centerY.equalToSuperview().offset(-Constants.formOriginYDecrement)
                        })

                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
        },
                       completion: nil)


        // Clear the MGP logo from the bottom
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseIn], animations: {
            self.mgpLogoView.alpha = 0
            self.mgpLogoLabel.alpha = 0

            self.loginFormView.alpha = 1
        }) { (finished) in
            self.mgpLogoView.removeFromSuperview()
            self.mgpLogoLabel.removeFromSuperview()
        }

        if shouldOpenKeyboardOnIntro {
            let deadlineTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(300)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.emailField.becomeFirstResponder()
            }
        }
    }

    // MARK: - Button Events

    @objc func didPressPasswordRecoveryButton() {
        if let url = URL(string: WebUrls.passwordResetUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func didPressCreateAccountButton() {
        if let url = URL(string: WebUrls.accountRegistrationUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
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
        authApi.login(email, password: password) { (error) in
            if let _ = error {
                // TODO: Handle errors. At least, display in screen.
                print("Login error \(error.debugDescription)!")

                self.loginButton.isLoading = false
                self.freezeLoginForm(false)
            } else {
                self.presentHome(transition: .flipHorizontal)
            }
        }
    }

    @objc func didPressLegalButton() {
        if let url = URL(string: WebUrls.termsOfUseUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

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
        let raceListNC = UINavigationController(rootViewController: raceListVC)
        raceListNC.modalTransitionStyle = transition
        raceListNC.modalPresentationStyle = .fullScreen

        present(raceListNC, animated: true, completion: nil)
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
