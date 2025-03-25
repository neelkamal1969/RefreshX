//
//  ExerciseModels.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//


import Foundation

struct Exercise: Identifiable, Codable, ExerciseRelated {
    let id: UUID
    var title: String
    var duration: Int
    var description: String
    var thumbnailImage: String
    var mainImage: String
    var reps: Int?
    var sets: Int?
    var instructions: String
    var focusArea: FocusArea
    var otherFocusAreas: [String]? // Changed to String array
    var motivationalTipTitle: String?
    var motivationalContent: String?
    var commonMistakeContent: String?
    var info: String?
    var whatsInItForYou: String?
    var link: String?
    var videoLink: String?
    var metValue: Double
    var addedDate: Date
    var isAddedToRoutine: Bool = false
    
    var instructionSteps: [String] {
        return instructions.components(separatedBy: CharacterSet(charactersIn: ".\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var totalDuration: Int {
        let repetitions = (sets ?? 1) * (reps ?? 1)
        return duration * repetitions
    }
    
    var formattedDuration: String {
        let minutes = totalDuration / 60
        return minutes < 1 ? "\(totalDuration) sec" : "\(minutes) min"
    }
    
    func calculateCaloriesBurned(userWeightKg: Double) -> Double {
        return metValue * userWeightKg * (Double(totalDuration) / 3600.0)
    }
}
struct Routine: Identifiable, Codable {
    let id: UUID
    var userId: UUID
    var eyeExercises: [UUID] = []
    var backExercises: [UUID] = []
    var wristExercises: [UUID] = []
    var lastUpdated: Date = Date()
    
    var numberOfExercises: Int {
        return eyeExercises.count + backExercises.count + wristExercises.count
    }
    
        // Total time in minutes
    var totalTime: Int {
        let dataManager = DataManager.shared
        let totalSeconds = (eyeExercises + backExercises + wristExercises)
            .compactMap { dataManager.getExercise(id: $0)?.totalDuration }
            .reduce(0, +)
        return totalSeconds / 60
    }
    
        // Total calories burned
    var totalCaloriesBurned: Double {
        guard let userWeight = DataManager.shared.userSettings?.userWeight else { return 0 }
        return (eyeExercises + backExercises + wristExercises)
            .compactMap { DataManager.shared.getExercise(id: $0)?.calculateCaloriesBurned(userWeightKg: userWeight) }
            .reduce(0, +)
    }
    
        // Main focus area
    var mainFocusArea: FocusArea? {
        let counts = [eyeExercises.count, backExercises.count, wristExercises.count]
        guard let maxCount = counts.max(), maxCount > 0 else { return nil }
        switch counts.firstIndex(of: maxCount) {
        case 0: return .eye
        case 1: return .back
        case 2: return .wrist
        default: return nil
        }
    }
    
    func exercisesFor(focusArea: FocusArea) -> [UUID] {
        switch focusArea {
        case .eye: return eyeExercises
        case .back: return backExercises
        case .wrist: return wristExercises
        case .wellness: return []
        }
    }
    
    mutating func addExercise(_ exerciseId: UUID, focusArea: FocusArea) {
        switch focusArea {
        case .eye: if !eyeExercises.contains(exerciseId) { eyeExercises.append(exerciseId) }
        case .back: if !backExercises.contains(exerciseId) { backExercises.append(exerciseId) }
        case .wrist: if !wristExercises.contains(exerciseId) { wristExercises.append(exerciseId) }
        case .wellness: break
        }
        lastUpdated = Date()
    }
    
    mutating func removeExercise(_ exerciseId: UUID, focusArea: FocusArea) {
        switch focusArea {
        case .eye: eyeExercises.removeAll { $0 == exerciseId }
        case .back: backExercises.removeAll { $0 == exerciseId }
        case .wrist: wristExercises.removeAll { $0 == exerciseId }
        case .wellness: break
        }
        lastUpdated = Date()
    }
    
    func containsExercise(_ exerciseId: UUID) -> Bool {
        return eyeExercises.contains(exerciseId) || backExercises.contains(exerciseId) || wristExercises.contains(exerciseId)
    }
}
struct ExerciseSession: Identifiable, Codable, Trackable, ExerciseRelated {
    let id: UUID
    let userId: UUID
    let exerciseId: UUID
    var exerciseTitle: String
    var startTime: Date
    var endTime: Date?
    var pausedDuration: Int // Total paused time in seconds
    var caloriesBurned: Double
    var completed: Bool
    var focusArea: FocusArea
    var lastUpdated: Date
    var isPaused: Bool
    var pauseStartTime: Date? // Tracks when the session was paused

    init(id: UUID = UUID(), userId: UUID, exerciseId: UUID, exerciseTitle: String, startTime: Date = Date(), endTime: Date? = nil, pausedDuration: Int = 0, caloriesBurned: Double = 0, completed: Bool = false, focusArea: FocusArea, lastUpdated: Date = Date()) throws {
        guard !exerciseTitle.isEmpty else { throw ValidationError.invalidTitle }
        guard pausedDuration >= 0 else { throw ValidationError.invalidPausedDuration }
        guard caloriesBurned >= 0 else { throw ValidationError.invalidCalories }
        self.id = id
        self.userId = userId
        self.exerciseId = exerciseId
        self.exerciseTitle = exerciseTitle
        self.startTime = startTime
        self.endTime = endTime
        self.pausedDuration = pausedDuration
        self.caloriesBurned = caloriesBurned
        self.completed = completed
        self.focusArea = focusArea
        self.lastUpdated = lastUpdated
        self.isPaused = false
        self.pauseStartTime = nil
    }

    var activeDuration: Int {
        guard let end = endTime else { return 0 }
        let totalDuration = Int(end.timeIntervalSince(startTime))
        return max(0, totalDuration - pausedDuration)
    }

    var formattedDuration: String {
        let minutes = activeDuration / 60
        return minutes < 1 ? "\(activeDuration) sec" : "\(minutes) min"
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(startTime)
    }

    mutating func pause() {
        guard !isPaused, endTime == nil, !completed else { return }
        isPaused = true
        pauseStartTime = Date() // Record when the pause started
        lastUpdated = Date()
    }

    mutating func resume() {
        guard isPaused, endTime == nil, !completed else { return }
        if let pauseStart = pauseStartTime {
            pausedDuration += Int(Date().timeIntervalSince(pauseStart)) // Add elapsed pause time
        }
        isPaused = false
        pauseStartTime = nil // Clear pause start time
        lastUpdated = Date()
    }

    mutating func complete(calories: Double) {
        guard !completed, endTime == nil else { return }
        if isPaused, let pauseStart = pauseStartTime {
            pausedDuration += Int(Date().timeIntervalSince(pauseStart)) // Add final pause time
        }
        endTime = Date()
        completed = true
        caloriesBurned = max(0, calories)
        isPaused = false
        pauseStartTime = nil
        lastUpdated = Date()
    }

    enum ValidationError: Error {
        case invalidTitle
        case invalidPausedDuration
        case invalidCalories
    }
}
