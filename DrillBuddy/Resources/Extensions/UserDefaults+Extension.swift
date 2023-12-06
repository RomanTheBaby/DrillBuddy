//
//  UserDefaults+Extension.swift
//  DrillBuddy
//
//  Created by Roman on 2023-12-05.
//

import Foundation

extension UserDefaults {
    var favoriteConfiguration: DrillRecordingConfiguration {
        get {
            guard let data = UserDefaults.standard.data(forKey: "Favorite.Configuration"),
                  let storedValue = try? JSONDecoder().decode(DrillRecordingConfiguration.self, from: data) else {
                return .default
            }
            
            return storedValue
        }
        set {
            do {
                let encodedConfiguration = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encodedConfiguration, forKey: "Favorite.Configuration")
            } catch {
                
            }
        }
    }
}
