//
//  ChapterConstants.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

//TIERS = array(1=>'Tier 1', 2=>'Tier 2', 3=>'Tier 3', 4=>'Special Event', 5=>'Provisional')
public enum ChapterTier: Int {
    case tier1 = 1
    case tier2 = 2
    case tier3 = 3
    case special = 4
    case provisional = 5

    public var title: String {
        switch self {
        case .tier1:        return "Tier 1"
        case .tier2:        return "Tier 2"
        case .tier3:        return "Tier 3"
        case .special:      return "Special"
        case .provisional:  return "Provisional"
        }
    }
}
