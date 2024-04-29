//
//  SceneDelegate.swift
//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var user: User?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        user = loadUser() ?? createDefaultUser()
        setupUserNotifications()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if let user = self.user {
            saveUser(user)
        }
    }

    private func loadUser() -> User? {
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            return user
        }
        return nil
    }

    func saveUser(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "userData")
        }
    }

    private func createDefaultUser() -> User {
        return User(username: "Unknown",
                    goals: User.UserGoals(caloriesGoal: 2000, proteinGoal: 60, stepsGoal: 5000),
                    currentAmounts: User.CurrentAmounts(currentCalories: 0, currentProtein: 0, currentSteps: 0),
                    allLoggedFoods: [])
    }

    private func setupUserNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                self.scheduleMealReminders()
            } else if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }

    private func scheduleMealReminders() {
        scheduleNotification(title: "Breakfast Reminder", body: "You haven't logged your breakfast!", hour: 12, identifier: "breakfastReminder")
        scheduleNotification(title: "Lunch Reminder", body: "You haven't logged your lunch!", hour: 16, identifier: "lunchReminder")
        scheduleNotification(title: "Dinner Reminder", body: "You haven't logged your dinner!", hour: 21, identifier: "dinnerReminder")
    }

    private func scheduleNotification(title: String, body: String, hour: Int, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling \(identifier): \(error)")
            }
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Perform background fetch tasks
        // Call recordDailySummary method
        let currentDate = Date()

        if let user = self.user {
            user.recordDailySummary(date: currentDate)
        }
        // Call the completion handler after finishing the task
        completionHandler(.newData)
    }
}

