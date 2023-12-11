//
//  AppRemoteConfig.swift
//  DrillBuddy
//
//  Created by Roman on 2023-12-05.
//

import Foundation

struct AppRemoteConfig: Hashable, Codable {
    struct MainTabBar: Hashable, Codable {
        var showSettings: Bool
        var showTournaments: Bool
    }
    
    struct SettingsTab: Hashable, Codable {
        var showLogInButton: Bool
    }
    
    var mainTabBar: MainTabBar
    var settingsTab: SettingsTab
    
    static let `default` = AppRemoteConfig(
        mainTabBar: MainTabBar(
            showSettings: false,
            showTournaments: false
        ),
        settingsTab: SettingsTab(
            showLogInButton: false
        )
    )
}
