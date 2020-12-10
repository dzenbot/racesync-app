//
//  RateMe.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-23.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//
//  Adaptation of SwiftlyRater
//  Created by Gianluca Di Maggio on 1/2/17.
//  Copyright © 2017 dima. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol RateMeProtocol {
    func rateMeDidShowPrompt() -> Void
    func rateMeDidTapRate() -> Void
    func rateMeDidTapDecline() -> Void
    func rateMeDidTapRemind() -> Void
}

/// A simple and lightweight Review Manager for iOS, written in Swift
public class RateMe: NSObject {

    public static var sharedInstance = RateMe()
    public var appId: String?
    public weak var delegate: RateMeProtocol?

    // MARK: - Public methods

    /*
     * Calling this function will show the Rater alert if all
     * the following conditions are satisfied:
     * 1) Network is available
     * 2) Users has not declined to rate this version
     * 3) Users has not rated this version already
     * 4) No version has been rated OR a new version will ask for a review anyhow
     * 5) Remind was never tapped OR it was tapped and enough days have gone by since then
     * 6) Enough signiicants Events have happened OR enough Uses
     */
    public func showPromptIfNeeded() {
        guard !self.didDeclineToRate else { // 1
            self.debugLog("User declined to rate current app version")
            return
        }

        guard !self.didRateCurrentVersion else { // 2
            self.debugLog("Current version has been rated already")
            return
        }

        guard !self.didRateAnyVersion || self.shouldPromptIfRated else { // 3
            self.debugLog("One version rated already, won't ask to rate again")
            return
        }

        if let lastReminded = self.lastReminded { // 4
            guard  let daysElapsed = Calendar.current.dateComponents([.day], from: lastReminded, to: Date()).day,
                daysElapsed >= self.daysBeforeReminding else {
                    self.debugLog("Not enough days (\(self.daysBeforeReminding)) since last reminder: \(lastReminded)")
                    return
            }
        }

        guard self.useCount >= self.usesUntilPrompt || self.eventsCount >= self.eventsUntilPrompt else { // 6
            self.debugLog("Uses \(self.useCount)/\(self.usesUntilPrompt), Events \(self.eventsCount)/\(self.eventsUntilPrompt)")
            return
        }

        self.showPrompt()
    }

    /*
     * Use this method to inform SR that a significant event has been
     * performed by the user and increasing the events count.
     */
    public func userDidPerformEvent(showPrompt: Bool) {
        self.eventsCount += 1

        if showPrompt {
            self.showPromptIfNeeded()
        }
    }

    // MARK: - Public State for Rater logic

    /*
     * Times the app needs to be launched before Rater is shown
     * Default: 10
     */
    public var usesUntilPrompt: Int = RateMeConstants.usesUntilPrompt

    /*
     * Days the app needs to be used before Rater is shown
     * Default: 5
     */
    public var daysUntilPrompt: Int = RateMeConstants.daysUntilPrompt

    /*
     * Specific/Custom events that need to happen before Rater is shown
     * Default: 10
     */
    public var eventsUntilPrompt: Int = RateMeConstants.eventsUntilPrompt

    /*
     * Days before the Rater is shown again
     * Default: 1
     */
    public var daysBeforeReminding: Int = RateMeConstants.daysBeforeReminding

    /*
     * By default, users will be asked to rate each new verion of the app
     * regardless of whether they already rated a previous version or not.
     * By setting this to false, users that have left a review already will
     * not be asked to leave another review again.
     */
    public var shouldPromptIfRated: Bool = true

    /*
     * By default, the prompt will be shown when the App launches,
     * i.e. when appDidFinishLaunchingWithOptions returns.
     * To show the prompt at a different time, set this property
     * to false and call 'showPromptIfNeeded' when needed.
     */
    public var shouldPrompAtLaunch: Bool = true

    /*
     * By default, the alert only shows two options: Rate Now and Remind Later
     * By setting this property to true, a third option will be added to the alert,
     * givin users the change to dismiss the Alert so that it won't show up again
     * (but only for the current version)
     */
    public var showNeverRemindButton = false

    /*
     * By default, RateMe will use its own localization files.
     * If you want to provide custom localization, set this property
     * to true and provide 'SRLocalizable.strings' in your main bundle.
     */
    public var useCustomLocalizationFile = false

    // MARK: - Configurable UI elements

    /*
     * Retrieved by application plist if Nil, can be overwritten
     */
    public var applicationName: String? = nil

    /*
     * Title of the Alert
     */
    public var reviewTitle: String = RateMeConstants.reviewTitle

    /*
     * Content of the Alert
     */
    public var reviewMessage: String = RateMeConstants.reviewMessage

    /*
     * Title of of the Rate button
     */
    public var rateButtonTitle: String = RateMeConstants.rateButtonTitle

    /*
     * Title of the Remind button
     */
    public var remindButtonTitle: String = RateMeConstants.remindButtonTitle

    /*
     * Title of the Never Remind button
     */
    public var neverRemindButtonTitle: String = RateMeConstants.neverRemindButtonTitle

    /*
     * Will enable debug logs
     */
    public var debug: Bool = false
    public var showPreview: Bool = false

    // MARK: - Lifecycle

    override private init() {
        super.init()
        setup()
    }

    private func setup(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidFinishLaunching) ,
                                               name: UIApplication.didFinishLaunchingNotification, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationWillResignActive) ,
                                               name: UIApplication.willResignActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationWillEnterForeground) ,
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private methods

    @objc private func applicationWillResignActive() {
        UserDefaults.RateMeDefaults.synchronize()
    }

    @objc private func applicationWillEnterForeground() {
        UserDefaults.RateMeDefaults.synchronize()
    }

    @objc private func applicationDidFinishLaunching() {

        // Check if ever used or version change
        if self.firstUse == nil || (self.lastVersionUsed != self.currentVersion) {
            self.resetStateForNewVersion()
        }

        // Increment use count
        self.useCount += 1

        let appName = self.applicationName ?? self.applicationNameBundle
        let versionRated = self.lastVersionRated ?? "N/A"
        self.debugLog("Name:\(appName), CurrentVersion:\(self.currentVersion), LastRatedVersion:\(versionRated), RatedCurrentVersion:\(self.didRateCurrentVersion), Uses:\(self.useCount), Events:\(self.eventsCount)")

        if self.showPreview {
            self.showPrompt()
        } else if self.shouldPrompAtLaunch {
            self.showPromptIfNeeded()
        }
    }

    private func showPrompt() {
        self.debugLog("Showing Rate prompt")

        // Dynamically create title by swapping in the application name
        let appName = self.applicationName ?? self.applicationNameBundle
        let reviewTitle = self.reviewTitle.localized(bundle: self.bundle).replacingOccurrences(of: "%@",
                                                                                               with: appName,
                                                                                               options: String.CompareOptions(rawValue: 0),
                                                                                               range: nil)

        let rateAlert = UIAlertController(title: reviewTitle,
                                          message: self.reviewMessage.localized(bundle: self.bundle),
                                          preferredStyle: .alert)
        let itunesAction = UIAlertAction(title: self.rateButtonTitle.localized(bundle: self.bundle),
                                         style: .cancel,
                                         handler: { (action) -> Void in
                                            guard let appId = self.appId, let url = self.appstoreURL(with: appId) else {
                                                self.debugLog("Please provide a valid AppId")
                                                return
                                            }

                                            UIApplication.shared.open(url, options: [:], completionHandler: { (completed) in
                                                self.lastVersionRated = self.currentVersion
                                            })
                                            self.delegate?.rateMeDidTapRate()
        })

        let remindAction = UIAlertAction(title: self.remindButtonTitle.localized(bundle: self.bundle),
                                         style: .default,
                                         handler: { (action) -> Void in
                                            self.lastReminded = Date()
                                            self.delegate?.rateMeDidTapRemind()
        })

        rateAlert.addAction(remindAction)
        rateAlert.addAction(itunesAction)

        if self.showNeverRemindButton {
            rateAlert.addAction(
                UIAlertAction(title: self.neverRemindButtonTitle.localized(bundle: self.bundle),
                              style: .default,
                              handler: { (action) -> Void in
                                self.didDeclineToRate = true
                                self.delegate?.rateMeDidTapDecline()
                })
            )
        }

        DispatchQueue.main.async {
            self.topViewController?.present(rateAlert, animated: true, completion: {
                self.delegate?.rateMeDidShowPrompt()
            })
        }
    }

    private func appstoreURL(with appId: String) -> URL? {
        let url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appId)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
        return URL(string: url)
    }

    // MARK: - Internal State

    private var didDeclineToRate: Bool {
        set {
            UserDefaults.RateMeDefaults.set(newValue, forKey: .declinedToRate)
            UserDefaults.RateMeDefaults.synchronize()
        }
        get {
            return UserDefaults.RateMeDefaults.bool(forKey: .declinedToRate)
        }
    }

    private var didRateCurrentVersion: Bool {
        guard let lastVersionRated = self.lastVersionRated else {
            return false
        }

        let result = lastVersionRated.compare(self.currentVersion, options: .numeric, range: nil, locale: nil)
        return result != ComparisonResult.orderedAscending // Left op. is either same or greater than right op.
    }

    private var lastVersionRated: String? {
        set {
            UserDefaults.RateMeDefaults.set(newValue, forKey: .versionRated)
            UserDefaults.RateMeDefaults.synchronize()
        }
        get {
            return UserDefaults.RateMeDefaults.string(forKey: .versionRated)
        }
    }

    private var didRateAnyVersion: Bool {
        return (self.lastVersionRated != nil)
    }

    private var currentVersion: String {
        let currentVersionShort = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let currentVersionBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        return currentVersionShort ?? currentVersionBundle ?? "0.0.0"
    }

    private var lastVersionUsed: String? {
        set {
            UserDefaults.RateMeDefaults.set(newValue, forKey: .lastVersionUsed)
            UserDefaults.RateMeDefaults.synchronize()
        }
        get {
            return UserDefaults.RateMeDefaults.string(forKey: .lastVersionUsed)
        }
    }

    private var lastReminded: Date? {
        set {
            UserDefaults.RateMeDefaults.set(newValue?.timeIntervalSince1970, forKey: .lastReminded)
            UserDefaults.RateMeDefaults.synchronize()
        }
        get {
            return UserDefaults.RateMeDefaults.date(forKey: .lastReminded)
        }
    }

    private var firstUse: Date? {
        set {
            UserDefaults.RateMeDefaults.set(newValue?.timeIntervalSince1970, forKey: .firstUse)
            UserDefaults.RateMeDefaults.synchronize()
        }
        get {
            return UserDefaults.RateMeDefaults.date(forKey: .firstUse)
        }
    }

    private var useCount: Int {
        set {
            UserDefaults.RateMeDefaults.set(newValue, forKey: .usesCount)
            UserDefaults.RateMeDefaults.synchronize()
        }
        get {
            return UserDefaults.RateMeDefaults.int(forKey: .usesCount)
        }
    }

    private var eventsCount: Int {
        set {
            UserDefaults.RateMeDefaults.set(newValue, forKey: .eventsCount)
            UserDefaults.RateMeDefaults.synchronize()
        }
        get {
            return UserDefaults.RateMeDefaults.int(forKey: .eventsCount)
        }
    }

    /*
     * The Alert will automaticall retrieve the App name from 
     * the bundle if none has been set by the user on initialization
     */
    private var applicationNameBundle: String {
        let applicationNameDisplay = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String
        let applicationNameBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
        return applicationNameDisplay ?? applicationNameBundle ?? "This App"
    }

    // MARK: - Helper

    /*
     * Use RateMe bundle by default, else use host application
     * bundle if 'self.useCustomLocalizationFile' is set to true
     */
    private var bundle: Bundle {
        if self.useCustomLocalizationFile {
            return Bundle.main
        } else {
            return Bundle(for: type(of: self))
        }
    }
    
    /*
     * Set all the usage stats back to the initial value,
     * i.e. every app updates is de facto treated as a fresh install
     *
     */
    private func resetStateForNewVersion() -> Void {
        self.useCount = 0
        self.eventsCount = 0
        self.didDeclineToRate = false
        self.firstUse = Date()
        self.lastReminded = nil
        self.lastVersionUsed = self.currentVersion

        self.debugLog("New version detected, resetting internal state")
    }

    private var topViewController: UIViewController? {
        var topController: UIViewController? = UIApplication.shared.windows.first?.rootViewController
        var isPresenting = false
        repeat {
            if let controller = topController {
                if let presented = controller.presentedViewController {
                    isPresenting = true
                    topController = presented
                } else {
                    isPresenting = false
                }
            }
        } while isPresenting
        return topController
    }
    
    private func debugLog(_ text: String) {
        guard self.debug else { return }
        
        print("[RateMe]: \(text)")
    }
    
}

extension String {
    func localized(bundle: Bundle) -> String {
        return bundle.localizedString(forKey: self, value: "", table: "SRLocalizable")
    }
}
