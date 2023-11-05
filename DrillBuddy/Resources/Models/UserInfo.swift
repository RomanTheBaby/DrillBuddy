//
//  UserInfo.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-02.
//

import Foundation
import FirebaseAuth

struct UserInfo: Hashable {
    var id: String
    var username: String
    var email: String
}

extension UserInfo {
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.username = firebaseUser.displayName ?? firebaseUser.email ?? ""
        self.email = firebaseUser.email ?? ""
    }
}
