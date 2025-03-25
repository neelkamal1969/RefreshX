//
//  BreakModels.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//


import Foundation

struct BreakSession: Identifiable, Codable, Trackable {
    let id: UUID
    let userId: UUID
    var scheduledTime: Date
    var startTime: Date?
    var endTime: Date?
    var duration: Int // intended duration in seconds
    var actualDuration: Int? // actual duration if completed
    var exercisesCompleted: [UUID]
    var skipped: Bool
    var completed: Bool
    var lastUpdated: Date
    
    init(id: UUID = UUID(), userId: UUID, scheduledTime: Date, duration: Int, exercisesCompleted: [UUID] = [], skipped: Bool = false, completed: Bool = false, lastUpdated: Date = Date()) throws {
        guard duration >= 60 else { throw ValidationError.invalidDuration } // Min 1 minute
        self.id = id
        self.userId = userId
        self.scheduledTime = scheduledTime
        self.startTime = nil
        self.endTime = nil
        self.duration = duration
        self.actualDuration = nil
        self.exercisesCompleted = exercisesCompleted
        self.skipped = skipped
        self.completed = completed
        self.lastUpdated = lastUpdated
    }
    
    var notificationTime: Date {
        let minutesBefore = DataManager.shared.userSettings?.remindersBefore ?? 5
        return Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: scheduledTime) ?? scheduledTime
    }
    
    var isActive: Bool {
        startTime != nil && endTime == nil
    }
    
    var isUpcoming: Bool {
        !completed && !skipped && scheduledTime > Date()
    }
    
    var minutesUntil: Int? {
        guard isUpcoming else { return nil }
        let interval = scheduledTime.timeIntervalSince(Date())
        return max(0, Int(interval) / 60)
    }
    
    mutating func startBreak() {
        guard !isActive, !completed, !skipped else { return }
        startTime = Date()
        lastUpdated = Date()
    }
    
    mutating func endBreak(completedExerciseIds: [UUID]) {
        guard isActive, !completed else { return }
        endTime = Date()
        completed = true
        exercisesCompleted.append(contentsOf: completedExerciseIds)
        if let start = startTime {
            actualDuration = max(0, Int(endTime!.timeIntervalSince(start)))
        }
        lastUpdated = Date()
    }
    
    mutating func skipBreak() {
        guard !completed, !skipped else { return }
        skipped = true
        lastUpdated = Date()
    }
    
    enum ValidationError: Error {
        case invalidDuration
    }
}
