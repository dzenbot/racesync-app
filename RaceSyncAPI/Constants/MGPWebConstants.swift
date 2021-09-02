//
//  MGPWebConstant.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public enum MGPWebConstant: String {
    case home = "https://www.multigp.com/"
    case apiBase = "https://www.multigp.com/mgp/multigpwebservice/"

    case s3Url = "https://multigp-storage-new.s3.us-east-2.amazonaws.com"
    case imgixUrl = "https://multigp.imgix.net"

    case passwordReset = "https://www.multigp.com/initiatepasswordreset"
    case accountRegistration = "https://www.multigp.com/register"
    case termsOfUse = "https://www.multigp.com/terms-of-use/"
    case shop = "https://www.multigp.com/shop/"

    case raceView = "https://www.multigp.com/races/view/?race"
    case chapterView = "https://www.multigp.com/chapters/view/?chapter"
    case userView = "https://www.multigp.com/pilots/view/?pilot"

    case feedbackPrefilledForm = "https://docs.google.com/forms/d/e/1FAIpQLSfY9qr-5I7JYtQ5s5UsVflMyXu-iW3-InzG03qAJOwGv9P1Tg/viewform"
    case feedbackRepo = "https://github.com/MultiGP/community-report/issues"

    case utt1LapPrefilledForm = "https://docs.google.com/forms/d/e/1FAIpQLSelYrIpRIe9fklG2Bqkqqxe_U94OelGqQZe8WkVtFFqXBP1Cw/viewform"
    case utt3LapPrefilledForm = "https://docs.google.com/forms/d/e/1FAIpQLScZCVu5TOacjjXrSWb3dof2t3amD6LA3biaNETWgyc9zK7LVA/viewform"

    case courseObstaclesDoc = "https://www.multigp.com/multigp-drone-race-course-obstacles/"
    case seasonRulesDoc = "http://docs.google.com/document/d/1GROA7Z6KgINhVDonuZ359zxOzWmmwbPV6H5xsU_wvgY/"

    case gqValidationFeet = "https://www.multigp.com/championships/2020-qualifier-track-dimension-worksheet-feet/"
    case gqValidationMeters = "https://www.multigp.com/championships/2020-qualifier-track-dimension-worksheet-meters/"
}

public class MGPWeb {

    public static func getURL(for constant: MGPWebConstant) -> URL {
        let url = getUrl(for: constant)
        return URL(string: url)!
    }

    public static func getUrl(for constant: MGPWebConstant, value: String? = nil) -> String {

        var baseUrl = constant.rawValue
        if APIServices.shared.settings.isDev {
            baseUrl = constant.rawValue.replacingOccurrences(of: "www", with: "test")
        }

        if let value = value {
            return "\(baseUrl)=\(value.replacingOccurrences(of: " ", with: "-", options: .literal, range: nil))"
        } else {
            return baseUrl
        }
    }

    public static func getPrefilledFeedbackFormUrl() -> String? {
        guard var urlComponents = URLComponents(string: MGPWebConstant.feedbackPrefilledForm.rawValue) else { return nil }
        var queryItems = [URLQueryItem]()

        guard let user = APIServices.shared.myUser else { return nil }

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
        return getPrefilledUTTFormUrl(MGPWebConstant.utt1LapPrefilledForm.rawValue, track: track)
    }

    public static func getPrefilledUTT3LapPrefilledFormUrl(_ track: Track) -> String? {
        return getPrefilledUTTFormUrl(MGPWebConstant.utt3LapPrefilledForm.rawValue, track: track)
    }

    public static func getPrefilledUTTFormUrl(_ formUrl: String, track: Track) -> String? {
        guard var urlComponents = URLComponents(string: formUrl) else { return nil }
        var queryItems = [URLQueryItem]()

        guard let user = APIServices.shared.myUser, let chapter = APIServices.shared.myChapter else { return nil }

        let fullname = "\(user.firstName) \(user.lastName)"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
