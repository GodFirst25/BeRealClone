//
//  Post.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    var originalData: Data?
    
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    
    var caption: String?
    var imageFile: ParseFile?
    var user: AppUser?
    
    init() { 
        self.originalData = nil
    }
}

extension Post: Identifiable {
    var id: String? { objectId }
}
