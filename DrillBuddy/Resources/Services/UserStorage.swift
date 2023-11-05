//
//  UserStorage.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-02.
//

import Foundation
import FirebaseAuth

class UserStorage: ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var currentUser: UserInfo?
    
    // MARK: - Init
    
    init(userInfo: UserInfo? = nil, listenToAuthStateChanges: Bool = true) {
        if let userInfo {
            currentUser = userInfo
            objectWillChange.send()
        } else if let firebaseUser = Auth.auth().currentUser {
            currentUser = UserInfo(firebaseUser: firebaseUser)
        }
        
        if listenToAuthStateChanges {
            Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
                if let firebaseUser {
                    self?.currentUser = UserInfo(firebaseUser: firebaseUser)
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
}
