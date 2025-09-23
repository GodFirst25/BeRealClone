//
//  User.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import Foundation
import ParseSwift

struct AppUser: ParseUser {
    var emailVerified: Bool?
    
    var authData: [String : [String : String]?]?
    
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var username: String?
    var email: String?
    var password: String?
    
    var fullName: String?
}
