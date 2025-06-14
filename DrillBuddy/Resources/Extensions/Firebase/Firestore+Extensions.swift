//
//  Firestore+Extensions.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-02.
//

import Foundation
import FirebaseFirestore


extension Firestore {
    
    // MARK: - Collection
    
    enum Collection: String {
        case usernames
        case tournaments
        case leaderboards
        case leaderboardReports
    }
    
    // MARK: - Public Methods
    
    func collection(_ param: Collection) -> CollectionReference {
        collection(param.rawValue)
    }
}
