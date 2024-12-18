//
//  AppWebConstants.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-18.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

public class AppWebConstants {
    static let homepage = "https://www.multigp.com/"
    static let passwordReset = "https://www.multigp.com/initiatepasswordreset"
    static let accountRegistration = "https://www.multigp.com/register"
    static let termsOfUse = "https://www.multigp.com/terms-of-use/"
    static let shop = "https://www.multigp.com/shop/"

    static let feedbackPrefilledForm = "https://docs.google.com/forms/d/e/1FAIpQLSfY9qr-5I7JYtQ5s5UsVflMyXu-iW3-InzG03qAJOwGv9P1Tg/viewform"
    static let feedbackRepo = "https://github.com/MultiGP/community-report/issues"

    static let utt1LapPrefilledForm = "https://docs.google.com/forms/d/e/1FAIpQLSelYrIpRIe9fklG2Bqkqqxe_U94OelGqQZe8WkVtFFqXBP1Cw/viewform"
    static let utt3LapPrefilledForm = "https://docs.google.com/forms/d/e/1FAIpQLScZCVu5TOacjjXrSWb3dof2t3amD6LA3biaNETWgyc9zK7LVA/viewform"

    static let courseObstaclesDoc = "https://www.multigp.com/multigp-drone-race-course-obstacles/"
    static let seasonRulesDoc = "https://docs.google.com/document/d/1jWVjCnoIGdW1j_bklrbg-0D24c3x6YG5m_vmF7faG-U/"

    static let gqValidationFeet = "https://www.multigp.com/championships/2020-qualifier-track-dimension-worksheet-feet/"
    static let gqValidationMeters = "https://www.multigp.com/championships/2020-qualifier-track-dimension-worksheet-meters/"

    static let betaSignup = "https://testflight.apple.com/join/BRXIQJLb"

    static let livefpv = "https://livefpv.com/"
    static let fpvscores = "https://fpvscores.com/"
}

extension AppWebConstants {
    public static func getPrefilledFeedbackFormUrl() -> String? {
        guard let user = APIServices.shared.myUser else { return nil }

        guard var urlComponents = URLComponents(string: feedbackPrefilledForm) else { return nil }
        var queryItems = [URLQueryItem]()

        let fullname = "\(user.firstName) \(user.lastName)"
        let username = user.userName
        queryItems.append(URLQueryItem(name: "entry.3082215", value: fullname))

        if let email = APISessionManager.getSessionEmail() {
            queryItems.append(URLQueryItem(name: "entry.1185283391", value: email))
        }

        queryItems.append(URLQueryItem(name: "entry.1807575595", value: username))

        urlComponents.queryItems = queryItems
        return urlComponents.url?.absoluteString
    }

    public static func getPrefilledUTT1LapPrefilledFormUrl(_ track: Track) -> String? {
        return getPrefilledUTTFormUrl(utt1LapPrefilledForm, track: track)
    }

    public static func getPrefilledUTT3LapPrefilledFormUrl(_ track: Track) -> String? {
        return getPrefilledUTTFormUrl(utt3LapPrefilledForm, track: track)
    }

    public static func getPrefilledUTTFormUrl(_ formUrl: String, track: Track) -> String? {
        guard var urlComponents = URLComponents(string: formUrl) else { return nil }
        var queryItems = [URLQueryItem]()

        guard let user = APIServices.shared.myUser, let chapter = APIServices.shared.myChapter else { return nil }

        let fullname = "\(user.firstName) \(user.lastName)"

        let formatter = DateFormatter()
        formatter.dateFormat = StandardDateFormat
        let dateString = formatter.string(from: Date())

        // Append the new query item in the existing query items array
        queryItems.append(URLQueryItem(name: "entry.348091437", value: "Yes"))          // needs to accept form first
        queryItems.append(URLQueryItem(name: "entry.1800936478", value: fullname))

        queryItems.append(URLQueryItem(name: "entry.1639711361", value: track.title))   // track name
        queryItems.append(URLQueryItem(name: "entry.1305427815", value: dateString))    // date of event (today)

        queryItems.append(URLQueryItem(name: "entry.111335806", value: chapter.name))
        queryItems.append(URLQueryItem(name: "entry.167275231", value: chapter.phone))

        if let email = APISessionManager.getSessionEmail() {
            queryItems.append(URLQueryItem(name: "entry.1231628105", value: email))
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url?.absoluteString
    }
}

enum AppWeb: Int {
    case multigp, livefpv, fpvscores

    init?(url: String) {
        guard let aURL = URL(string: url) else { return nil }

        let mappings: [AppWeb: String] = [
            .multigp: AppWebConstants.homepage,
            .livefpv: AppWebConstants.livefpv,
            .fpvscores: AppWebConstants.fpvscores
        ]

        for (appWebCase, caseURLString) in mappings {
            if let caseURL = URL(string: caseURLString),
               caseURL.rootDomain == aURL.rootDomain {
                self = appWebCase
                return
            }
        }

        return nil
    }
}
