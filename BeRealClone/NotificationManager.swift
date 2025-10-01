//
//  CommentCell.swift
//  BeRealClone
//
//  Created by olamide mercy oduntan on 9/30/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request notification permissions
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
            } else if let error = error {
                print("❌ Notification permissions error: \(error)")
            } else {
                print("❌ Notification permissions denied")
            }
        }
    }
    
    // Schedule daily notification reminder
    func scheduleNotification() {
        
        // Remove existing notifications first
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to BeReal! 📸"
        content.body = "Share what you're doing right now with your friends"
        content.sound = .default
        
        // Schedule notification every 24 hours
        // You can adjust this interval as needed
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "bereal_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled for 24 hours from now")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ All notifications cancelled")
    }
}
