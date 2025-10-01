//
//  User.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import Foundation
import ParseSwift

struct AppUser: ParseUser {
    
    // Required ParserUser properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Standard user properties
    var username: String?
    var email: String?
    var password: String?
    var emailVerified: Bool?
    var authData: [String : [String : String]?]?
    
    var fullName: String?
    
    // PART 2: Tracks when user last posted to determine post visibility
    var lastPostDate: Date?
}

struct Post: ParseObject {
    
    // Required ParseObject properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Post properties
    var caption: String?
    var user: AppUser?
    var imageFile: ParseFile?
    
    // PART 2: Location data for posts
    var location: String?
    var latitude: Double?
    var longitude: Double?
}

// PART 2: Comment Model for post comments
struct Comment: ParseObject {
    
    // Required ParseObject properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Comment properties
    var text: String?
    var user: AppUser?
    var post: Post?
}
