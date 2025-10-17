//
//  RootView.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import SwiftUI
import ParseSwift

struct RootView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn, let user = AppUser.current {
                MainFeedView()
                    .onAppear {
                        print("✅ Logged in as: \(user.username ?? "Unknown")")
                    }
            } else {
                AuthenticationView()
                    .onAppear {
                        print("📱 Showing AuthenticationView")
                    }
            }
        }
        .onAppear {
            print("🔍 isLoggedIn: \(isLoggedIn)")
            print("🔍 AppUser.current: \(AppUser.current?.username ?? "nil")")
            
            if AppUser.current != nil {
                isLoggedIn = true
            } else {
                isLoggedIn = false
            }
        }
    }
}
