//
//  AppDelegate.swift
//  BeRealClone
//
//  Created by student on 9/22/25.
//

import UIKit
import ParseSwift


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // 🔑 Replace with your Back4App credentials
        ParseSwift.initialize(
            applicationId: "IghbmdtiVfng8NqfZrI2IcN5cjWkiazHTUJmgucK",
            clientKey: "EuAIv9e9gIKXzGyydp9B4pigDAG4mCUnC2WhMmvN",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
        
        print("✅ Parse initialized successfully")
        return true
    }
}
