//
//  UserModels.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

//neelkamal

import Foundation
import CryptoKit

/// User model
class User: Identifiable, Codable {
    let id: UUID
    var name: String
    let email: String
    private var passwordHash: String
    var dateOfBirth: Date
    var readArticleIds: [UUID]?
    var notificationIds: [UUID]?
    var weekdays: Int // Number of work days (1-7)
    var jobStartTime: Date
    var jobEndTime: Date
    var numberOfBreaksPreferred: Int
    var breakDuration: Int // in minutes
    var isAdmin: Bool = false
    var routineId: UUID?
    var profileImageName: String?
    var createdAt: Date
    
    /// Computed property for total work duration in minutes
    var workDurationMinutes: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: jobStartTime, to: jobEndTime)
        return max(0, (components.hour ?? 0) * 60 + (components.minute ?? 0)) // Ensure non-negative
    }
    
    /// Computed property for recommended break duration based on work hours
    var recommendedBreakDuration: Int {
        guard numberOfBreaksPreferred > 0 else { return 15 } // Default 15 min if no breaks
        let totalBreakTime = Int(Double(workDurationMinutes) * 0.2)
        let recommendedDuration = totalBreakTime / numberOfBreaksPreferred
        return min(max(recommendedDuration, 5), 30) // Cap between 5 and 30 minutes
    }
    
    /// Total break duration in minutes
    var totalBreakDuration: Int {
        return breakDuration * numberOfBreaksPreferred
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, passwordHash, dateOfBirth, readArticleIds, notificationIds,
             weekdays, jobStartTime, jobEndTime, numberOfBreaksPreferred, breakDuration,
             isAdmin, routineId, profileImageName, createdAt
    }
    
    init(id: UUID = UUID(),
         name: String,
         email: String,
         password: String,
         dateOfBirth: Date,
         readArticleIds: [UUID]? = nil,
         notificationIds: [UUID]? = nil,
         weekdays: Int = 5,
         jobStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0, second: 0)) ?? Date(),
         jobEndTime: Date = Calendar.current.date(from: DateComponents(hour: 17, minute: 0, second: 0)) ?? Date(),
         numberOfBreaksPreferred: Int = 5,
         breakDuration: Int = 15,
         isAdmin: Bool = false,
         routineId: UUID? = nil,
         profileImageName: String? = nil,
         createdAt: Date = Date()) throws {
        
        // Validations
        guard Self.isValidEmail(email) else { throw ValidationError.invalidEmail }
        guard !name.isEmpty else { throw ValidationError.invalidName }
        guard !password.isEmpty else { throw ValidationError.invalidPassword }
        guard weekdays >= 1 && weekdays <= 7 else { throw ValidationError.invalidWeekdays }
        guard numberOfBreaksPreferred >= 0 else { throw ValidationError.invalidBreaksPreferred }
        guard breakDuration >= 5 && breakDuration <= 60 else { throw ValidationError.invalidBreakDuration }
        guard jobStartTime < jobEndTime else { throw ValidationError.invalidWorkHours }
        
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = User.hashPassword(password)
        self.dateOfBirth = dateOfBirth
        self.readArticleIds = readArticleIds
        self.notificationIds = notificationIds
        self.weekdays = weekdays
        self.jobStartTime = jobStartTime
        self.jobEndTime = jobEndTime
        self.numberOfBreaksPreferred = numberOfBreaksPreferred
        self.breakDuration = breakDuration
        self.isAdmin = isAdmin
        self.routineId = routineId
        self.profileImageName = profileImageName
        self.createdAt = createdAt
    }
    
    /// Verify user password
    func verifyPassword(_ password: String) -> Bool {
        return passwordHash == User.hashPassword(password)
    }
    
    /// Update user password
    func updatePassword(_ newPassword: String) throws {
        guard !newPassword.isEmpty else { throw ValidationError.invalidPassword }
        self.passwordHash = User.hashPassword(newPassword)
    }
    
    /// Hash password for secure storage
    private static func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Validate email format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case invalidName
        case invalidPassword
        case invalidWeekdays
        case invalidBreaksPreferred
        case invalidBreakDuration
        case invalidWorkHours
    }
}

/// User Settings model
struct UserSettings: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var notificationsEnabled: Bool
    var breakRemindersEnabled: Bool
    var exerciseRemindersEnabled: Bool
    var soundEnabled: Bool
    var autoStartBreaksEnabled: Bool
    var darkModeEnabled: Bool
    var userWeight: Double? // in kg, for calorie calculations
    var userHeight: Double? // in cm
    var remindersBefore: Int // minutes before scheduled break
    var readAloudEnabled: Bool
    var largeTextEnabled: Bool
    var lastUpdated: Date
    
    init(id: UUID = UUID(),
         userId: UUID,
         notificationsEnabled: Bool = true,
         breakRemindersEnabled: Bool = true,
         exerciseRemindersEnabled: Bool = true,
         soundEnabled: Bool = true,
         autoStartBreaksEnabled: Bool = false,
         darkModeEnabled: Bool = false,
         userWeight: Double? = nil,
         userHeight: Double? = nil,
         remindersBefore: Int = 5,
         readAloudEnabled: Bool = false,
         largeTextEnabled: Bool = false,
         lastUpdated: Date = Date()) throws {
        
        guard remindersBefore >= 1 && remindersBefore <= 30 else { throw ValidationError.invalidRemindersBefore }
        guard userWeight == nil || userWeight! >= 20 else { throw ValidationError.invalidWeight }
        guard userHeight == nil || userHeight! >= 50 else { throw ValidationError.invalidHeight }
        
        self.id = id
        self.userId = userId
        self.notificationsEnabled = notificationsEnabled
        self.breakRemindersEnabled = breakRemindersEnabled
        self.exerciseRemindersEnabled = exerciseRemindersEnabled
        self.soundEnabled = soundEnabled
        self.autoStartBreaksEnabled = autoStartBreaksEnabled
        self.darkModeEnabled = darkModeEnabled
        self.userWeight = userWeight
        self.userHeight = userHeight
        self.remindersBefore = remindersBefore
        self.readAloudEnabled = readAloudEnabled
        self.largeTextEnabled = largeTextEnabled
        self.lastUpdated = lastUpdated
    }
    
    /// Computed property for BMI if weight and height are set
    var bmi: Double? {
        guard let weight = userWeight, let height = userHeight, height > 0 else { return nil }
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    /// Computed property for BMI category
    var bmiCategory: String? {
        guard let bmi = bmi else { return nil }
        switch bmi {
        case ..<18.5: return "Underweight"
        case ..<25: return "Normal"
        case ..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    enum ValidationError: Error {
        case invalidRemindersBefore
        case invalidWeight
        case invalidHeight
    }
}

/// Streak model - tracks user's usage streaks
struct Streak: Identifiable, Codable, Trackable {
    let id: UUID
    let userId: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var streakMilestones: [Int]
    var lastUpdated: Date
    
    init(id: UUID = UUID(), userId: UUID, currentStreak: Int = 0, longestStreak: Int = 0, lastActivityDate: Date? = nil, streakMilestones: [Int] = [], lastUpdated: Date = Date()) throws {
        guard currentStreak >= 0, longestStreak >= 0 else { throw ValidationError.invalidStreak }
        self.id = id
        self.userId = userId
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActivityDate = lastActivityDate
        self.streakMilestones = streakMilestones
        self.lastUpdated = lastUpdated
    }
    
    /// Update streak based on activity date
    mutating func recordActivity(date: Date = Date()) {
        let calendar = Calendar.current
        if let lastDate = lastActivityDate {
            let daysDifference = calendar.dateComponents([.day], from: lastDate, to: date).day ?? 0
            if daysDifference == 1 {
                currentStreak += 1 // Yesterday
            } else if daysDifference == 0 {
                // Same day, no change
            } else {
                currentStreak = 1 // Gap > 1 day or past
            }
        } else {
            currentStreak = 1 // First activity
        }
        
        longestStreak = max(longestStreak, currentStreak)
        
        let milestones = [7, 14, 21, 30, 60, 90, 180, 365]
        for milestone in milestones where currentStreak == milestone && !streakMilestones.contains(milestone) {
            streakMilestones.append(milestone)
        }
        
        lastActivityDate = date
        lastUpdated = Date()
    }
    
    /// Check if streak is active today
    var isActiveToday: Bool {
        guard let lastDate = lastActivityDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    enum ValidationError: Error {
        case invalidStreak
    }
}
