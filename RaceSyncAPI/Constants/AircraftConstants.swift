//
//  AircraftConstants.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

//TYPES = array(0=>'Tri',1=>'Quad', 2=>'Hex', 3=>'Octo', 5=>'Winged', 4=>'Other')
public enum AircraftType: String, EnumTitle {
    case tri = "0"
    case quad = "1"
    case hex = "2"
    case octo = "3"
    case winged = "5"
    case other = "4"

    public var title: String {
        switch self {
        case .tri:          return "Tricopter"
        case .quad:         return "Quadcopter"
        case .hex:          return "Hexacopter"
        case .octo:         return "Octocopter"
        case .winged:       return "Winged"
        case .other:        return "Other"
        }
    }
}

//SIZES = array(7=>'120-149',8=>'150-179',9=>'180-219',10=>'220-249',0=>'250-279',1=>'280-299',2=>'300-229',3=>'330-399',4=>'400-449',5=>'450-499',6=>'500')
public enum AircraftSize: String, EnumTitle {
    case under120 = "11"
    case from120 = "7"
    case from150 = "8"
    case from180 = "9"
    case from220 = "10"
    case from250 = "0"
    case from280 = "1"
    case from300 = "2"
    case from330 = "3"
    case from400 = "4"
    case from450 = "5"
    case from500 = "6"
    case from800 = "13"

    public var title: String {
        switch self {
        case .under120:      return "Under 120mm (Tiny Whoop)"
        case .from120:       return "120mm to 149mm"
        case .from150:       return "150mm to 179mm"
        case .from180:       return "180mm to 219mm"
        case .from220:       return "220mm to 249mm"
        case .from250:       return "250mm to 279mm"
        case .from280:       return "280mm to 299mm"
        case .from300:       return "300mm to 329mm"
        case .from330:       return "330mm to 399mm"
        case .from400:       return "400mm to 449mm"
        case .from450:       return "450mm to 499mm"
        case .from500:       return "500mm to 675mm"
        case .from800:       return "800mm to 1050mm (Mega Class)"
        }
    }
}

//WING_SIZES = array(0=>'450', 1=>'600', 2=>'900', 3=>'1200')
public enum WingSize: String, EnumTitle {
    case from450 = "0"
    case from600 = "1"
    case from900 = "2"
    case from1200 = "3"

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
public enum VideoTxType: String, EnumTitle {
    case ´900mhz´ = "0"
    case ´1300mhz´ = "1"
    case ´2400mhz´ = "2"
    case ´5800mhz´ = "3"

    public var title: String {
        switch self {
        case .´900mhz´:     return "900 mhz"
        case .´1300mhz´:    return "1.3 GHz"
        case .´2400mhz´:    return "2.4 GHz"
        case .´5800mhz´:    return "5.8 GHz"
        }
    }
}

//VIDEO_TRANSMITTER_POWERS = array(0=>'10 mW',8=>'25 mW',1=>'50 mW',2=>'200 mW',3=>'250 mW',7=>'350 mW',4=>'400 mW',5=>'600 mW',6=>'1000 mW')
public enum VideoTxPower: String, EnumTitle {
    case ´10mw´ = "0"
    case ´25mw´ = "8"
    case ´50mw´ = "1"
    case ´200mw´ = "2"
    case ´250mw´ = "3"
    case ´350mw´ = "7"
    case ´400mw´ = "4"
    case ´600mw´ = "5"
    case ´1000mw´ = "6"

    public var title: String {
        switch self {
        case .´10mw´:       return "25 mW"
        case .´25mw´:       return "25 mW"
        case .´50mw´:       return "50 mW"
        case .´200mw´:      return "200 mW"
        case .´250mw´:      return "250 mW"
        case .´350mw´:      return "350 mW"
        case .´400mw´:      return "400 mW"
        case .´600mw´:      return "600 mW"
        case .´1000mw´:     return "1000 mW"
        }
    }
}

//VIDEO_TRANSMITTER_CHANNELS = array(0=>'Immersion / Fatshark 8 Channel',1=>'Boscam 8 Channel',2=>'Boscam 32 Channel',3=>'Raceband 40')
public enum VideoChannels: String, EnumTitle {
    case fatshark = "0"
    case boscam8 = "1"
    case boscam32 = "2"
    case raceband40 = "3"

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
public enum AntennaPolarization: String, EnumTitle {
    case lhcp = "0"
    case rhcp = "1"
    case both = "2"

    public var title: String {
        switch self {
        case .lhcp:         return "Left"
        case .rhcp:         return "Right"
        case .both:         return "Both"
        }
    }
}

//BATTERIES = array(3=>'2 cell', 0=>'3 cell',1=>'4 cell',2=>'6 cell')
public enum BatterySize: String, EnumTitle {
    case ´1s´ = "4"
    case ´2s´ = "3"
    case ´3s´ = "0"
    case ´4s´ = "1"
    case ´6s´ = "2"
    case ´8s´ = "7"
    case ´12s´ = "8"

    public var title: String {
        switch self {
        case .´1s´:         return "1 Cell"
        case .´2s´:         return "2 Cells"
        case .´3s´:         return "3 Cells"
        case .´4s´:         return "4 Cells"
        case .´6s´:         return "6 Cells"
        case .´8s´:         return "8 Cells"
        case .´12s´:         return "12 Cells"
        }
    }
}

//PROPELLER_SIZES = array(11=>'31 mm', 12=>'40 mm', 6=>'2 inch', 7=>'2.5 inch', 8=>'3 inch', 9=>'4 inch', 0=>'5 inch',1=>'6 inch',2=>'7 inch',3=>'8 inch',4=>'9 inch',5=>'10 inch',10=>'13 inch')
public enum PropellerSize: String, EnumTitle {
    case ´31mm´ = "11"
    case ´40mm´ = "12"
    case ´2in´ = "6"
    case ´2in5´ = "7"
    case ´3in´ = "8"
    case ´4in´ = "9"
    case ´5in´ = "0"
    case ´6in´ = "1"
    case ´7in´ = "2"
    case ´8in´ = "3"
    case ´9in´ = "4"
    case ´10in´ = "5"
    case ´13in´ = "10"

    public var title: String {
        switch self {
        case .´31mm´:       return "31 mm"
        case .´40mm´:       return "40 mm"
        case .´2in´:        return "2 inch"
        case .´2in5´:       return "2.5 inch"
        case .´3in´:        return "3 inch"
        case .´4in´:        return "4 inch"
        case .´5in´:        return "5 inch"
        case .´6in´:        return "6 inch"
        case .´7in´:        return "7 inch"
        case .´8in´:        return "8 inch"
        case .´9in´:        return "9 inch"
        case .´10in´:       return "10 inch"
        case .´13in´:       return "13 inch"
        }
    }
}
