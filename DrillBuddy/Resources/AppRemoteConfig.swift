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
    
    var mainTabBar: MainTabBar
    
    static let `default` = AppRemoteConfig(
        mainTabBar: MainTabBar(
            showSettings: false,
            showTournaments: false
        )
    )
}
