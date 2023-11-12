//
//  UserStorage.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-02.
//

import Foundation
#if canImport(FirebaseAuth)
import FirebaseAuth
import FirebaseCrashlytics
#endif


class UserStorage: ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var currentUser: UserInfo?
    
    // MARK: - Init
    
    init(userInfo: UserInfo? = nil, listenToAuthStateChanges: Bool = true) {
        if let userInfo {
            currentUser = userInfo
            objectWillChange.send()
        } else {
            #if canImport(FirebaseAuth)
            if let firebaseUser = Auth.auth().currentUser {
                currentUser = UserInfo(firebaseUser: firebaseUser)
            }
            #endif
        }
        
        #if canImport(FirebaseAuth)
        if listenToAuthStateChanges {
            Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
                if let firebaseUser {
                    self?.currentUser = UserInfo(firebaseUser: firebaseUser)
                    Crashlytics.crashlytics().setUserID(firebaseUser.uid)
                } else {
                    self?.currentUser = nil
                }
            }
        }
        #endif
    }
}
