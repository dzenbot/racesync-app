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

    case passwordReset = "https://www.multigp.com/initiatepasswordreset"
    case accountRegistration = "https://www.multigp.com/register"
    case termsOfUse = "https://www.multigp.com/terms-of-use/"

    case raceView = "https://www.multigp.com/races/view/?race"
    case chapterView = "https://www.multigp.com/chapters/view/?chapter"
    case userView = "https://www.multigp.com/pilots/view/?pilot"

    case feedbackForm = "https://forms.gle/v7jYpjxW7fzBVzir7"
    case feedbackPrefilledForm = "https://docs.google.com/forms/d/e/1FAIpQLSfY9qr-5I7JYtQ5s5UsVflMyXu-iW3-InzG03qAJOwGv9P1Tg/viewform"
}

public class MGPWeb {

    public static func getURL(for constant: MGPWebConstant) -> URL {
        let url = getUrl(for: constant)
        return URL(string: url)!
    }

    public static func getUrl(for constant: MGPWebConstant) -> String {
        if APIServices.shared.settings.isDev {
            return constant.rawValue.replacingOccurrences(of: "www", with: "test")
        } else {
            return constant.rawValue
        }
    }

    public static func getPrefilledFeedbackFormUrl() -> String {
        guard let user = APIServices.shared.myUser else { return MGPWebConstant.feedbackForm.rawValue }

        let fullname = "\(user.firstName)+\(user.lastName)"
        let username = user.userName

        var url = MGPWebConstant.feedbackPrefilledForm.rawValue
        url += "?"
        url += "entry.3082215=\(fullname)"

        if let email = APISessionManager.getSessionEmail() {
            url += "&"
            url += "entry.1185283391=\(email)"
        }

        url += "&"
        url += "entry.1807575595=\(username)"

        url = url.replacingOccurrences(of: " ", with: "+")

        return url
    }
}
