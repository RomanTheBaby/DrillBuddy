//
//  UserStorageViewData.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-02.
//

import Foundation

actor UserStoragePreviewData {
    static let loggedOut = UserStorage(userInfo: nil, listenToAuthStateChanges: false)
    static let loggedIn = UserStorage(
        userInfo: UserInfo(id: "", username: "user_name", email: "email@em.com"),
        listenToAuthStateChanges: false
    )
}
