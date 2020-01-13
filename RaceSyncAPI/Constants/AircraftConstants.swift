//
//  AircraftConstants.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

//TYPES = array(0=>'Tri',1=>'Quad', 2=>'Hex', 3=>'Octo', 5=>'Winged', 4=>'Other')
public enum AircraftType: Int, EnumTitle {
    case tri = 0
    case quad = 1
    case hex = 2
    case octo = 3
    case other = 4
    case winged = 5

    public var title: String {
        switch self {
        case .tri:          return "Tri"
        case .quad:         return "Quad"
        case .hex:          return "Hex"
        case .octo:         return "Octo"
        case .other:        return "Other"
        case .winged:       return "Winged"
        }
    }
}

//SIZES = array(7=>'120-149',8=>'150-179',9=>'180-219',10=>'220-249',0=>'250-279',1=>'280-299',2=>'300-229',3=>'330-399',4=>'400-449',5=>'450-499',6=>'500')
public enum AircraftSize: Int {
    case from120 = 7
    case from150 = 8
    case from180 = 9
    case from220 = 10
    case from250 = 0
    case from280 = 1
    case from300 = 2
    case from330 = 3
    case from400 = 4
    case from450 = 5
    case from500 = 6

    public var title: String {
        switch self {
        case .from120:       return "120-149"
        case .from150:       return "150-179"
        case .from180:       return "180-219"
        case .from220:       return "220-249"
        case .from250:       return "250-279"
        case .from280:       return "280-299"
        case .from300:       return "300-329"
        case .from330:       return "330-399"
        case .from400:       return "400-449"
        case .from450:       return "450-499"
        case .from500:       return "500"
        }
    }
}

//WING_SIZES = array(0=>'450', 1=>'600', 2=>'900', 3=>'1200')
public enum WingSize: Int, EnumTitle {
    case from450 = 0
    case from600 = 1
    case from900 = 2
    case from1200 = 3

    public var title: String {
        switch self {
        case .from450:      return "450"
        case .from600:      return "600"
        case .from900:      return "900"
        case .from1200:     return "1200"
        }
    }
}

//VIDEO_TRANSMITTERS = array(0=>'900 mhz',1=>'1.3 GHz',2=>'2.4 GHz',3=>'5.8 GHz')
public enum VideoTxType: Int, EnumTitle {
    case ´900mhz´ = 0
    case ´1300mhz´ = 1
    case ´2400mhz´ = 2
    case ´5800mhz´ = 3

    public var title: String {
        switch self {
        case .´900mhz´:     return "900 mhz"
        case .´1300mhz´:    return "1.3 GHz"
        case .´2400mhz´:    return "2.4 GHz"
        case .´5800mhz´:    return "5.8 GHz"
        }
    }
}

//VIDEO_TRANSMITTER_POWERS = array(0=>'10 mw',1=>'50 mw',2=>'200 mw',3=>'250 mw',4=>'400 mw',5=>'600 mw',6=>'1000 mw')
public enum VideoTxPower: Int, EnumTitle {
    case ´10mw´ = 0
    case ´50mw´ = 1
    case ´200mw´ = 2
    case ´250mw´ = 3
    case ´400mw´ = 4
    case ´600mw´ = 5
    case ´1000mw´ = 6

    public var title: String {
        switch self {
        case .´10mw´:       return "10 mw"
        case .´50mw´:       return "50 mw"
        case .´200mw´:      return "200 mw"
        case .´250mw´:      return "250 mw"
        case .´400mw´:      return "400 mw"
        case .´600mw´:      return "600 mw"
        case .´1000mw´:     return "1000 mw"
        }
    }
}

//VIDEO_TRANSMITTER_CHANNELS = array(0=>'Immersion / Fatshark 8 Channel',1=>'Boscam 8 Channel',2=>'Boscam 32 Channel',3=>'Raceband 40')
public enum VideoChannels: Int, EnumTitle {
    case fatshark = 0
    case boscam8 = 1
    case boscam32 = 2
    case raceband40 = 3

    public var title: String {
        switch self {
        case .fatshark:     return "Immersion / Fatshark 8 Channel"
        case .boscam8:      return "Boscam 8 Channel"
        case .boscam32:     return "Boscam 32 Channel"
        case .raceband40:   return "Raceband 40"
        }
    }

    public static func bandTitle(for bandAcronym: String) -> String {
        switch bandAcronym {
        case "A":           return "Boscam A"
        case "B":           return "Boscam B"
        case "E":           return "Boscam E"
        case "F":           return "RC / FS"
        case "R":           return "Race Band"
        default:            return ""
        }
    }
}

//ANTENNAS = array(0=>'Left',1=>'Right',2=>'Both')
public enum AntennaPolarization: Int, EnumTitle {
    case lhcp = 0
    case rhcp = 1
    case both = 2

    public var title: String {
        switch self {
        case .lhcp:         return "2 Cells"
        case .rhcp:         return "3 Cells"
        case .both:         return "4 Cells"
        }
    }
}

//BATTERIES = array(3=>'2 cell', 0=>'3 cell',1=>'4 cell',2=>'6 cell')
public enum BatteryCellType: Int, EnumTitle {
    case ´3s´ = 0
    case ´4s´ = 1
    case ´6s´ = 2
    case ´2s´ = 3

    public var title: String {
        switch self {
        case .´3s´:         return "3 Cells"
        case .´4s´:         return "4 Cells"
        case .´6s´:         return "6 Cells"
        case .´2s´:         return "2 Cells"
        }
    }
}

// TODO: Convert to Enum: Int
//PROPELLER_SIZES = array(6=>'2 inch', 7=>'2.5 inch', 8=>'3 inch', 9=>'4 inch', 0=>'5 inch',1=>'6 inch',2=>'7 inch',3=>'8 inch',4=>'9 inch',5=>'10 inch')
public enum PropellerSize: String {
    case ´2in´ = "2 inch"
    case ´2in5´ = "2.5 inch"
    case ´3in´ = "3 inch"
    case ´4in´ = "4 inch"
    case ´5in´ = "5 inch"
    case ´6in´ = "6 inch"
    case ´7in´ = "7 inch"
    case ´8in´ = "8 inch"
    case ´9in´ = "9 inch"
    case ´10in´ = "10 inch"
    case ´13in´ = "13 inch"
}
