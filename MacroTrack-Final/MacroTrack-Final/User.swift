//
//  User.swift
//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024
//

import Foundation
import CoreMotion

import Foundation
import CoreMotion

class User: Codable {
    // Define a structure for storing the user's goals
    struct UserGoals: Codable {
        var caloriesGoal: Int
        var proteinGoal: Int
        var stepsGoal: Int
    }

    // Define a structure for storing the user's current amounts
    struct CurrentAmounts: Codable {
        var currentCalories: Int
        var currentProtein: Int
        var currentSteps: Int
    }
    // Define a structure for storing food items
    struct FoodItem: Codable, Equatable {
        var name: String
        var calories: Int
        var protein: Int
    }
    
    // Define a structure to hold daily summary data
    struct DailySummary: Codable {
        var date: Date
        var caloriesEaten: Int
        var proteinConsumed: Int
        var stepsTaken: Int
    }

    var username: String
    var goals: UserGoals
    var currentAmounts: CurrentAmounts
    var allLoggedFoods: [FoodItem] // Array to hold all logged foods
    var foodsEatenToday: [FoodItem] = [] // Array to hold foods eaten today
    var history: [DailySummary] = [] // Array to hold daily summaries

    // Core Motion properties
    private let motionManager = CMPedometer()
    private var totalSteps: Int = 0
    
    init(username: String, goals: UserGoals, currentAmounts: CurrentAmounts, allLoggedFoods: [FoodItem]) {
        self.username = username
        self.goals = goals
        self.currentAmounts = currentAmounts
        self.allLoggedFoods = allLoggedFoods
        
        // Request authorization for motion and fitness data
        requestAuthorization()
        
        // Start step tracking
        startStepTracking()
    }
    
    private func requestAuthorization() {
       let activityManager = CMMotionActivityManager()
       activityManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { activities, error in
           guard error == nil else {
               print("Error requesting authorization: \(error!.localizedDescription)")
               return
           }
           
           // Authorization is granted if activities are available
           if let activities = activities, !activities.isEmpty {
               print("Authorization granted for motion and fitness data.")
           } else {
               print("Authorization denied for motion and fitness data.")
           }
       }
   }
    
    // Helper method to start step tracking
    private func startStepTracking() {
        motionManager.startUpdates(from: Date()) { [weak self] pedometerData, error in
            if let steps = pedometerData?.numberOfSteps.intValue {
                self?.totalSteps = steps
                self?.updateCurrentSteps()
            }
        }
    }
    
    // Helper method to update current steps
    private func updateCurrentSteps() {
        currentAmounts.currentSteps = totalSteps
    }

    // Helper method to add a food item to today's foods
    func addFoodItemToToday(food: FoodItem) {
        foodsEatenToday.append(food)
        updateCurrentAmounts()
    }

    // Helper method to remove a food item from today's foods
    func removeFoodItemFromToday(at index: Int) {
        guard index >= 0 && index < foodsEatenToday.count else {
            print("Invalid index")
            return
        }
        foodsEatenToday.remove(at: index)
        updateCurrentAmounts()
    }
    // Helper method to remove a food item completely from a user
    func removeFoodItemFromAll(at index: Int) {
        guard index >= 0 && index < allLoggedFoods.count else {
            print("Invalid index")
            return
        }
        allLoggedFoods.remove(at: index)
        
        NotificationCenter.default.post(name: .userDidUpdateData, object: self)

    }

    // Helper method to update current amounts based on consumed food
    func updateCurrentAmounts() {
        // Calculate current amounts based on consumed food items
        let totalCalories = foodsEatenToday.reduce(0) { $0 + $1.calories }
        let totalProtein = foodsEatenToday.reduce(0) { $0 + $1.protein }

        // Update current amounts
        currentAmounts.currentCalories = totalCalories
        currentAmounts.currentProtein = totalProtein

        // Post notification
        NotificationCenter.default.post(name: .userDidUpdateData, object: self)
    }

    // Helper method to record daily summary
    func recordDailySummary(date: Date) {
        let dailySummary = DailySummary(date: date, caloriesEaten: currentAmounts.currentCalories, proteinConsumed: currentAmounts.currentProtein, stepsTaken: currentAmounts.currentSteps)
        history.append(dailySummary)
        currentAmounts.currentCalories = 0
        currentAmounts.currentProtein = 0
        currentAmounts.currentSteps = 0
    }

    // Codable protocol methods for encoding and decoding
    enum CodingKeys: String, CodingKey {
        case username, goals, currentAmounts, allLoggedFoods, history, foodsEatenToday
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        goals = try container.decode(UserGoals.self, forKey: .goals)
        currentAmounts = try container.decode(CurrentAmounts.self, forKey: .currentAmounts)
        allLoggedFoods = try container.decode([FoodItem].self, forKey: .allLoggedFoods)
        foodsEatenToday = try container.decode([FoodItem].self, forKey: .foodsEatenToday)

        history = try container.decode([DailySummary].self, forKey: .history)
        
        // Request authorization for motion and fitness data
        requestAuthorization()
        
        // Start step tracking
        startStepTracking()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(goals, forKey: .goals)
        try container.encode(currentAmounts, forKey: .currentAmounts)
        try container.encode(allLoggedFoods, forKey: .allLoggedFoods)
        try container.encode(foodsEatenToday, forKey: .foodsEatenToday)
        try container.encode(history, forKey: .history)
    }
}

extension Notification.Name {
    static let userDidUpdateData = Notification.Name("UserDidUpdateDataNotification")
}
