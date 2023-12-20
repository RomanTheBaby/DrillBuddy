//
//  EnvironmentKeys.swift
//  DrillBuddy
//
//  Created by Roman on 2023-12-20.
//

import SwiftUI

struct RemotConfigurationEnvironmentKey: EnvironmentKey {
    static var defaultValue: AppRemoteConfig = .default
}

extension EnvironmentValues {
  var remoteConfiguration: AppRemoteConfig {
    get { self[RemotConfigurationEnvironmentKey.self] }
    set { self[RemotConfigurationEnvironmentKey.self] = newValue }
  }
}
