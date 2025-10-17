//
//  User.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import Foundation
import ParseSwift

struct AppUser: ParseUser {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var username: String?
    var email: String?
    var password: String?
    var emailVerified: Bool?
    var authData: [String : [String : String]?]?
    var fullName: String?
    var lastPostDate: Date?
}

struct Post: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var caption: String?
    var user: AppUser?
    var imageFile: ParseFile?
    var location: String?
    var latitude: Double?
    var longitude: Double?
}

struct Comment: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var text: String?
    var user: AppUser?
    var post: Post?
}

extension Post: Identifiable {
    var id: String? { objectId }
}

extension Comment: Identifiable {
    var id: String? { objectId }
}
