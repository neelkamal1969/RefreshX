//
//  ProgressModels.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import Foundation

struct DailyProgress: Identifiable, Codable, Trackable {
    let id: UUID
    let userId: UUID
    let date: Date
    var completedExercises: Int
    var totalExercises: Int
    var completedBreaks: Int
    var totalBreaks: Int
    var screenTime: Int // in minutes
    var eyeExercisesCompleted: Int
    var eyeExercisesTotal: Int
    var eyeExerciseTime: Int // in seconds
    var backExercisesCompleted: Int
    var backExercisesTotal: Int
    var backExerciseTime: Int // in seconds
    var backFlexibilityScore: Double
    var wristExercisesCompleted: Int
    var wristExercisesTotal: Int
    var wristExerciseTime: Int // in seconds
    var wristStrengthScore: Double
    var totalCaloriesBurned: Double
    var lastUpdated: Date
    
    
    init(id: UUID = UUID(), userId: UUID, date: Date = Date(), completedExercises: Int = 0, totalExercises: Int? = nil, completedBreaks: Int = 0, totalBreaks: Int? = nil, userBreakPreference: Int? = nil, screenTime: Int = 0, eyeExercisesCompleted: Int = 0, eyeExercisesTotal: Int = 0, eyeExerciseTime: Int = 0, backExercisesCompleted: Int = 0, backExercisesTotal: Int = 0, backExerciseTime: Int = 0, backFlexibilityScore: Double = 0.0, wristExercisesCompleted: Int = 0, wristExercisesTotal: Int = 0, wristExerciseTime: Int = 0, wristStrengthScore: Double = 0.0, totalCaloriesBurned: Double = 0.0, lastUpdated: Date = Date(), routineExerciseCount: Int? = nil) throws {
        guard completedExercises >= 0, completedBreaks >= 0, screenTime >= 0 else { throw ValidationError.invalidCounts }
        guard eyeExercisesCompleted >= 0, eyeExercisesTotal >= 0, eyeExerciseTime >= 0 else { throw ValidationError.invalidEyeStats }
        guard backExercisesCompleted >= 0, backExercisesTotal >= 0, backExerciseTime >= 0, backFlexibilityScore >= 0 else { throw ValidationError.invalidBackStats }
        guard wristExercisesCompleted >= 0, wristExercisesTotal >= 0, wristExerciseTime >= 0, wristStrengthScore >= 0 else { throw ValidationError.invalidWristStats }
        guard totalCaloriesBurned >= 0 else { throw ValidationError.invalidCalories }
        
        self.id = id
        self.userId = userId
        self.date = date
        self.completedExercises = completedExercises
        self.totalExercises = totalExercises ?? routineExerciseCount ?? 0
        self.completedBreaks = completedBreaks
        self.totalBreaks = totalBreaks ?? userBreakPreference ?? 0
        self.screenTime = screenTime
        self.eyeExercisesCompleted = eyeExercisesCompleted
        self.eyeExercisesTotal = eyeExercisesTotal
        self.eyeExerciseTime = eyeExerciseTime
        self.backExercisesCompleted = backExercisesCompleted
        self.backExercisesTotal = backExercisesTotal
        self.backExerciseTime = backExerciseTime
        self.backFlexibilityScore = backFlexibilityScore
        self.wristExercisesCompleted = wristExercisesCompleted
        self.wristExercisesTotal = wristExercisesTotal
        self.wristExerciseTime = wristExerciseTime
        self.wristStrengthScore = wristStrengthScore
        self.totalCaloriesBurned = totalCaloriesBurned
        self.lastUpdated = lastUpdated
    }
    
    var dailyGoalPercentage: Double {
        guard totalExercises > 0 else { return 0 }
        return min(100.0, (Double(completedExercises) / Double(totalExercises)) * 100.0)
    }
    
    var breakCompletionPercentage: Double {
        guard totalBreaks > 0 else { return 0 }
        return min(100.0, (Double(completedBreaks) / Double(totalBreaks)) * 100.0)
    }
    
    mutating func addCompletedExercise(_ session: ExerciseSession) {
        guard session.completed, !Calendar.current.isDate(date, equalTo: session.startTime, toGranularity: .day) else { return }
        completedExercises += 1
        totalCaloriesBurned += session.caloriesBurned
        
        switch session.focusArea {
        case .eye:
            eyeExercisesCompleted += 1
            eyeExerciseTime += session.activeDuration
        case .back:
            backExercisesCompleted += 1
            backExerciseTime += session.activeDuration
        case .wrist:
            wristExercisesCompleted += 1
            wristExerciseTime += session.activeDuration
        case .wellness:
            break
        }
        lastUpdated = Date()
    }
    
    mutating func addCompletedBreak(_ breakSession: BreakSession, exercises: [UUID: Exercise], userWeight: Double?) {
        guard breakSession.completed, !Calendar.current.isDate(date, equalTo: breakSession.scheduledTime, toGranularity: .day) else { return }
        completedBreaks += 1
        
        for exerciseId in breakSession.exercisesCompleted {
            if let exercise = exercises[exerciseId],
               let weight = userWeight {
                
                let session = try? ExerciseSession(
                    userId: breakSession.userId,
                    exerciseId: exerciseId,
                    exerciseTitle: exercise.title,
                    startTime: breakSession.startTime ?? Date(),
                    endTime: breakSession.endTime ?? Date(),
                    caloriesBurned: exercise.calculateCaloriesBurned(userWeightKg: weight),
                    completed: true,
                    focusArea: exercise.focusArea
                )
                
                if let session = session {
                    addCompletedExercise(session)
                }
            }
        }
        lastUpdated = Date()
    }
    enum ValidationError: Error {
        case invalidCounts
        case invalidEyeStats
        case invalidBackStats
        case invalidWristStats
        case invalidCalories
    }
}

struct WeeklyStats: Identifiable, Codable, Trackable {
    let id: UUID
    let userId: UUID
    let weekStartDate: Date
    let weekEndDate: Date
    var averageDailyTime: Int
    var totalTime: Int
    var peakDayTime: Int
    var peakDayDate: Date?
    var goalCompletionPercentage: Double
    var growthPercentageSinceLastWeek: Double
    var exercisesCompleted: Int
    var exercisesTotal: Int
    var breaksCompleted: Int
    var breaksTotal: Int
    var eyeExerciseTime: Int
    var backExerciseTime: Int
    var wristExerciseTime: Int
    var totalCaloriesBurned: Double
    var streakDays: Int
    var lastUpdated: Date
    
    init(id: UUID = UUID(), userId: UUID, weekStartDate: Date, weekEndDate: Date, averageDailyTime: Int = 0, totalTime: Int = 0, peakDayTime: Int = 0, peakDayDate: Date? = nil, goalCompletionPercentage: Double = 0.0, growthPercentageSinceLastWeek: Double = 0.0, exercisesCompleted: Int = 0, exercisesTotal: Int = 0, breaksCompleted: Int = 0, breaksTotal: Int = 0, eyeExerciseTime: Int = 0, backExerciseTime: Int = 0, wristExerciseTime: Int = 0, totalCaloriesBurned: Double = 0.0, streakDays: Int = 0, lastUpdated: Date = Date()) throws {
        guard averageDailyTime >= 0, totalTime >= 0, peakDayTime >= 0 else { throw ValidationError.invalidTimes }
        guard exercisesCompleted >= 0, exercisesTotal >= 0, breaksCompleted >= 0, breaksTotal >= 0 else { throw ValidationError.invalidCounts }
        guard eyeExerciseTime >= 0, backExerciseTime >= 0, wristExerciseTime >= 0 else { throw ValidationError.invalidFocusTimes }
        guard totalCaloriesBurned >= 0, streakDays >= 0 else { throw ValidationError.invalidMetrics }
        guard weekStartDate <= weekEndDate else { throw ValidationError.invalidDateRange }
        
        self.id = id
        self.userId = userId
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.averageDailyTime = averageDailyTime
        self.totalTime = totalTime
        self.peakDayTime = peakDayTime
        self.peakDayDate = peakDayDate
        self.goalCompletionPercentage = goalCompletionPercentage
        self.growthPercentageSinceLastWeek = growthPercentageSinceLastWeek
        self.exercisesCompleted = exercisesCompleted
        self.exercisesTotal = exercisesTotal
        self.breaksCompleted = breaksCompleted
        self.breaksTotal = breaksTotal
        self.eyeExerciseTime = eyeExerciseTime
        self.backExerciseTime = backExerciseTime
        self.wristExerciseTime = wristExerciseTime
        self.totalCaloriesBurned = totalCaloriesBurned
        self.streakDays = streakDays
        self.lastUpdated = lastUpdated
    }
    
    func containsDate(_ date: Date) -> Bool {
        date >= weekStartDate && date <= weekEndDate
    }
    
    func weekOffset(from currentDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let currentWeekOfYear = calendar.component(.weekOfYear, from: currentDate)
        let thisWeekOfYear = calendar.component(.weekOfYear, from: weekStartDate)
        let currentYear = calendar.component(.year, from: currentDate)
        let thisYear = calendar.component(.year, from: weekStartDate)
        return (thisYear - currentYear) * 52 + (thisWeekOfYear - currentWeekOfYear)
    }
    
    static func fromDailyProgress(_ dailyRecords: [DailyProgress]) -> WeeklyStats? {
        guard !dailyRecords.isEmpty else { return nil }
        let userId = dailyRecords[0].userId
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dailyRecords[0].date))!
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        
        let stats = try? WeeklyStats(id: UUID(), userId: userId, weekStartDate: weekStart, weekEndDate: weekEnd)
        guard var stats = stats else { return nil }
        var peakTime = 0
        
        for record in dailyRecords.filter({ stats.containsDate($0.date) }) {
            stats.exercisesCompleted += record.completedExercises
            stats.exercisesTotal += record.totalExercises
            stats.breaksCompleted += record.completedBreaks
            stats.breaksTotal += record.totalBreaks
            stats.eyeExerciseTime += record.eyeExerciseTime
            stats.backExerciseTime += record.backExerciseTime
            stats.wristExerciseTime += record.wristExerciseTime
            stats.totalCaloriesBurned += record.totalCaloriesBurned
            stats.totalTime += record.eyeExerciseTime + record.backExerciseTime + record.wristExerciseTime
            let dayTime = record.eyeExerciseTime + record.backExerciseTime + record.wristExerciseTime
            if dayTime > peakTime {
                peakTime = dayTime
                stats.peakDayTime = peakTime
                stats.peakDayDate = record.date
            }
        }
        stats.averageDailyTime = stats.totalTime / max(1, dailyRecords.count)
        stats.goalCompletionPercentage = stats.exercisesTotal > 0 ? Double(stats.exercisesCompleted) / Double(stats.exercisesTotal) * 100 : 0
        stats.lastUpdated = Date()
        return stats
    }
    
    enum ValidationError: Error {
        case invalidTimes
        case invalidCounts
        case invalidFocusTimes
        case invalidMetrics
        case invalidDateRange
    }
}
