//
//  Enums.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//


import Foundation

enum FocusArea: String, Codable, CaseIterable, Identifiable {
    case eye = "Eye"
    case back = "Back"
    case wrist = "Wrist"
    case wellness = "Wellness"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .eye: return "eye"
        case .back: return "figure.walk"
        case .wrist: return "hand.raised"
        case .wellness: return "heart"
        }
    }
}

enum NotificationType: String, Codable {
    case breakReminder = "Break Reminder"
    case exerciseCompleted = "Exercise Completed"
    case allExercisesCompleted = "All Exercises Completed"
    case dailyGoalAchieved = "Daily Goal Achieved"
    case streakMilestone = "Streak Milestone"
    case missedBreak = "Missed Break"
    case missedExercise = "Missed Exercise"
    case newArticleAdded = "New Article Added"
    case reminderToRead = "Reminder to Read"
    case tipOfTheDay = "Tip of the Day"
    
    static let tips: [String] = [
        "Drink water to stay hydrated and reduce eye strain.",
        "Take a 5-minute walk to refresh your mind.",
        "Blink often to keep your eyes moist.",
        "Stretch your wrists to prevent stiffness.",
        "Adjust your screen brightness for comfort.",
        "Practice deep breathing for relaxation."
    ]
    
    var triggerTime: Date? {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        
        switch self {
        case .reminderToRead:
            components.hour = 12
            components.minute = 0
            components.second = 0
        case .tipOfTheDay:
            components.hour = 18
            components.minute = 0
            components.second = 0
        default:
            return nil
        }
        guard let triggerDate = calendar.date(from: components) else { return nil }
        return triggerDate > now ? triggerDate : calendar.date(byAdding: .day, value: 1, to: triggerDate)
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateAddedNewest = "Newest First"
    case dateAddedOldest = "Oldest First"
    case durationLongest = "Longest Duration"
    case durationShortest = "Shortest Duration"
    case alphabeticalAZ = "A-Z"
    case alphabeticalZA = "Z-A"
    case readTimeHighest = "Longest Read"
    case readTimeLowest = "Shortest Read"
    var id: String { rawValue }
}

enum TrackingMetric: String, Codable {
    case screenTime = "Screen Time"
    case flexibility = "Flexibility Score"
    case strength = "Strength Score"
    case focus = "Focus Score"
    case coordination = "Coordination"
}

enum TimeFrame: String, Codable {
    case today = "Today"
    case thisWeek = "This Week"
}
