//
//  GunType.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-30.
//

import Foundation

enum GunType: Hashable, Codable {
    case any
    case pistol
    case rifle
    case shotgun
    
    var description: String {
        switch self {
        case .any:
            return "Any"
        case .pistol:
            return "Pistol"
        case .rifle:
            return "Rifle"
        case .shotgun:
            return "Shotgun"
        }
    }
}


enum GunActionType: Hashable, Codable {
    case any
    case lever
    case pump
    case semiAuto
    
    var description: String {
        switch self {
        case .any:
            return "Any"
        case .lever:
            return "Lever"
        case .pump:
            return "Pump"
        case .semiAuto:
            return "Semi-Auto"
        }
    }
}
