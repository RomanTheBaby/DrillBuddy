//
//  NSUbiquitousKeyValueStore+Extension.swift
//  DrillBuddy
//
//  Created by Roman on 2023-10-31.
//

import Foundation

private let usernameKey: String = "com.DrillBuddy.UserName"

extension NSUbiquitousKeyValueStore {
    var username: String? {
        get {
            value(forKey: usernameKey) as? String
        }
        set {
            setValue(newValue, forKey: usernameKey)
        }
    }
}
