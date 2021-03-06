//
//  Enum & Structs.swift
//  PitTime
//
//  Created by 神村亮佑 on 2020/11/24.
//

import Foundation

// Fields within the User Document in Database
struct DatabaseUserField {
    static let displayName: String = "display_name"
    static let email: String = "email"
    static let providerID: String = "provider_id"
    static let provider: String = "provider"
    static let userID: String = "user_id"
    static let bio: String = "bio"
    static let dateCreated: String = "date_created"
}

// Fields within Post Document in Database
struct DatabasePostField {
    static let postID = "post_id"
    static let userID = "user_id"
    static let displayName = "display_name"
    static let pitBeginTime = "pit_begin_time"
    static let pitEndTime = "pit_end_time"
    static let dateCreated = "date_created"
}

// Fields for UserDefaults saved within app
struct CurrentUserDefaults {
    static let displayName = "display_name"
    static let bio = "bio"
    static let userID = "user_id"
    static let isFirstVisit = "is_first_visit"
    static let isFirstUpload = "is_first_upload"
}
