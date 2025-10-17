//
//  BeRealCloneApp.swift
//  BeRealClone
//
//  Created by student on 9/22/25.
//

import SwiftUI

@main
struct BeRealCloneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
