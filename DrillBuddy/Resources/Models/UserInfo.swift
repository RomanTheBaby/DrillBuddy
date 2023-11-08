//
//  UserInfo.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-02.
//

import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct UserInfo: Hashable {
    var id: String
    var username: String
    var email: String
}

#if canImport(FirebaseAuth)
extension UserInfo {
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.username = firebaseUser.displayName ?? firebaseUser.email ?? ""
        self.email = firebaseUser.email ?? ""
    }
}
#endif
