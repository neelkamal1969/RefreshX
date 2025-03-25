//
//  DataManager.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import Foundation
/// Central data manager with shared instance pattern
class DataManager {
    // Singleton instance
    static let shared = DataManager()
    
    // Current user
    private(set) var currentUser: User?
    
    // Data collections
    private(set) var exercises: [UUID: Exercise] = [:]
    private(set) var articles: [UUID: Article] = [:]
    private(set) var userRoutine: Routine?
    private(set) var notifications: [AppNotification] = []
    private(set) var exerciseSessions: [ExerciseSession] = []
    private(set) var breakSessions: [BreakSession] = []
    private(set) var dailyProgress: DailyProgress?
    private(set) var weeklyStats: WeeklyStats?
    private(set) var userSettings: UserSettings?
    private(set) var userStreak: Streak?
    

    
    // Private initializer for singleton
    private init() {
        // Automatically load sample data for development
        loadSampleData()
    }
    
    // MARK: - User Management
    
    /// Set the current user after successful login
    func setCurrentUser(_ user: User) {
        self.currentUser = user
        loadUserData()
    }
    
    /// Clear current user on logout
    func clearCurrentUser() {
        self.currentUser = nil
        clearUserData()
    }
    
    // MARK: - Data Loading
    
    /// Load all user-specific data
    func loadUserData() {
        guard let user = currentUser else { return }
        
        loadExercises()
        loadArticles()
        loadUserRoutine()
        loadNotifications()
        loadProgressData()
        loadUserSettings()
    }
    
    /// Clear all user-specific data
    func clearUserData() {
        exercises = [:]
        articles = [:]
        userRoutine = nil
        notifications = []
        exerciseSessions = []
        breakSessions = []
        dailyProgress = nil
        weeklyStats = nil
        userSettings = nil
        userStreak = nil
    }
    
    // MARK: - Sample Data Loading
    
    func loadExercises() {
        let sampleExercises = createSampleExercises()
        for exercise in sampleExercises {
            exercises[exercise.id] = exercise
        }
    }
    
    func loadArticles() {
        let sampleArticles = createSampleArticles()
        for article in sampleArticles {
            articles[article.id] = article
        }
    }
    
    func loadUserRoutine() {
        guard let user = currentUser, userRoutine == nil else { return }
        
        var eyeExerciseId: UUID? = nil
        var backExerciseId: UUID? = nil
        var wristExerciseId: UUID? = nil
        
        for exercise in exercises.values {
            switch exercise.focusArea {
            case .eye where eyeExerciseId == nil:
                eyeExerciseId = exercise.id
            case .back where backExerciseId == nil:
                backExerciseId = exercise.id
            case .wrist where wristExerciseId == nil:
                wristExerciseId = exercise.id
            default:
                break
            }
        }
        
        let routine = Routine(
            id: UUID(),
            userId: user.id,
            eyeExercises: eyeExerciseId != nil ? [eyeExerciseId!] : [],
            backExercises: backExerciseId != nil ? [backExerciseId!] : [],
            wristExercises: wristExerciseId != nil ? [wristExerciseId!] : []
        )
        
        userRoutine = routine
        
        if let id = eyeExerciseId { exercises[id]?.isAddedToRoutine = true }
        if let id = backExerciseId { exercises[id]?.isAddedToRoutine = true }
        if let id = wristExerciseId { exercises[id]?.isAddedToRoutine = true }
    }
    
    func loadNotifications() {
        guard let user = currentUser, notifications.isEmpty else { return }
        
        do {
            let sampleNotifications: [AppNotification] = [
                try AppNotification(
                    id: UUID(),
                    userId: user.id,
                    title: "Break Reminder",
                    message: "Time for a quick eye exercise!",
                    type: .breakReminder,
                    createdAt: Date().addingTimeInterval(-300)
                ),
                try AppNotification(
                    id: UUID(),
                    userId: user.id,
                    isRead: true,
                    title: "Streak Milestone",
                    message: "Congratulations on reaching a 7-day streak!",
                    type: .streakMilestone,
                    createdAt: Date().addingTimeInterval(-3600 * 24)
                ),
                try AppNotification(
                    id: UUID(),
                    userId: user.id,
                    title: "New Article Available",
                    message: "Check out our new article on eye care techniques!",
                    type: .newArticleAdded,
                    createdAt: Date().addingTimeInterval(-3600 * 3)
                )
            ]
            notifications = sampleNotifications
        } catch {
            print("Failed to load notifications: \(error)")
            notifications = []
        }
    }
    
    func loadProgressData() {
        guard let user = currentUser else { return }
        
        // Create sample daily progress if none exists
        if dailyProgress == nil {
            do {
                dailyProgress = try DailyProgress(
                    id: UUID(),
                    userId: user.id,
                    date: Date(),
                    completedExercises: 5,
                    totalExercises: 8,
                    completedBreaks: 2,
                    totalBreaks: 4,
                    screenTime: 360,
                    eyeExercisesCompleted: 2,
                    eyeExercisesTotal: 3,
                    eyeExerciseTime: 600,
                    backExercisesCompleted: 1,
                    backExercisesTotal: 2,
                    backExerciseTime: 300,
                    backFlexibilityScore: 8.5,
                    wristExercisesCompleted: 2,
                    wristExercisesTotal: 3,
                    wristExerciseTime: 450,
                    wristStrengthScore: 7.5,
                    totalCaloriesBurned: 120.5,
                    lastUpdated: Date()
                )
            } catch {
                print("Failed to create daily progress: \(error)")
                dailyProgress = nil // Keep nil if creation fails
            }
        }
        
        // Create sample weekly stats if none exist
        if weeklyStats == nil {
            let calendar = Calendar.current
            let today = Date()
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            do {
                weeklyStats = try WeeklyStats(
                    id: UUID(),
                    userId: user.id,
                    weekStartDate: weekStart,
                    weekEndDate: weekEnd,
                    averageDailyTime: 1800,
                    totalTime: 12600,
                    peakDayTime: 3600,
                    peakDayDate: calendar.date(byAdding: .day, value: -2, to: today),
                    goalCompletionPercentage: 75.0,
                    growthPercentageSinceLastWeek: 12.0,
                    exercisesCompleted: 22,
                    exercisesTotal: 28,
                    breaksCompleted: 18,
                    breaksTotal: 20,
                    eyeExerciseTime: 4500,
                    backExerciseTime: 3600,
                    wristExerciseTime: 4500,
                    totalCaloriesBurned: 850.0,
                    streakDays: 7,
                    lastUpdated: Date()
                )
            } catch {
                print("Failed to create weekly stats: \(error)")
                weeklyStats = nil
            }
        }
        
        // Create sample streak data if none exists
        if userStreak == nil {
            do {
                userStreak = try Streak(
                    id: UUID(),
                    userId: user.id,
                    currentStreak: 7,
                    longestStreak: 14,
                    lastActivityDate: Date(),
                    lastUpdated: Date()
                )
            } catch {
                print("Failed to create streak: \(error)")
                userStreak = nil
            }
        }
    }
    
    func loadUserSettings() {
        guard let user = currentUser, userSettings == nil else { return }
        
        do {
            userSettings = try UserSettings(
                id: UUID(),
                userId: user.id,
                notificationsEnabled: true,
                breakRemindersEnabled: true,
                exerciseRemindersEnabled: true,
                soundEnabled: true,
                autoStartBreaksEnabled: false,
                darkModeEnabled: false,
                userWeight: 70.0,
                userHeight: 170.0,
                lastUpdated: Date()
            )
        } catch {
            print("Failed to create user settings: \(error)")
            userSettings = nil
        }
    }
    
    // MARK: - Break Scheduling
    
    func calculateBreakSchedule() -> [Date] {
        guard let user = currentUser else { return [] }
        
        let calendar = Calendar.current
        var now = Date()
        var dayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        let startComponents = calendar.dateComponents([.hour, .minute], from: user.jobStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: user.jobEndTime)
        
        dayComponents.hour = startComponents.hour
        dayComponents.minute = startComponents.minute
        let startTime = calendar.date(from: dayComponents) ?? now
        
        dayComponents.hour = endComponents.hour
        dayComponents.minute = endComponents.minute
        let endTime = calendar.date(from: dayComponents) ?? now
        
        if now < startTime {
            now = startTime
        } else if now > endTime {
            return []
        }
        
        let workDuration = Int(endTime.timeIntervalSince(startTime))
        let breakInterval = workDuration / (user.numberOfBreaksPreferred + 1)
        
        var breakTimes: [Date] = []
        for i in 1...user.numberOfBreaksPreferred {
            let breakTime = startTime.addingTimeInterval(Double(breakInterval * i))
            if breakTime > now && breakTime < endTime {
                breakTimes.append(breakTime)
            }
        }
        
        return breakTimes
    }
    
    var nextBreakTime: Date? {
        let breakTimes = calculateBreakSchedule()
        return breakTimes.first
    }
    
    // MARK: - Progress Tracking
    
    func recordExerciseSession(_ session: ExerciseSession) {
        exerciseSessions.append(session)
        
        if dailyProgress == nil {
            do {
                dailyProgress = try DailyProgress(
                    id: UUID(),
                    userId: session.userId,
                    date: Date(),
                    lastUpdated: Date()
                )
            } catch {
                print("Failed to create daily progress in recordExerciseSession: \(error)")
                return // Exit early if creation fails
            }
        }
        
        dailyProgress?.addCompletedExercise(session)
        
        if userStreak == nil {
            do {
                userStreak = try Streak(id: UUID(), userId: session.userId)
            } catch {
                print("Failed to create streak in recordExerciseSession: \(error)")
                return
            }
        }
        userStreak?.recordActivity()
    }
    
    func recordBreakSession(_ session: BreakSession) {
        breakSessions.append(session)
        dailyProgress?.addCompletedBreak(session)
    }
    
    func exerciseCompletionPercentage(for focusArea: FocusArea) -> Double {
        guard let progress = dailyProgress else { return 0 }
        
        switch focusArea {
        case .eye:
            return progress.eyeExercisesTotal > 0 ?
            Double(progress.eyeExercisesCompleted) / Double(progress.eyeExercisesTotal) * 100 : 0
        case .back:
            return progress.backExercisesTotal > 0 ?
            Double(progress.backExercisesCompleted) / Double(progress.backExercisesTotal) * 100 : 0
        case .wrist:
            return progress.wristExercisesTotal > 0 ?
            Double(progress.wristExercisesCompleted) / Double(progress.wristExercisesTotal) * 100 : 0
        case .wellness:
            return 0
        }
    }
    
    func timeSpent(for focusArea: FocusArea, timeFrame: TimeFrame = .today) -> Int {
        switch timeFrame {
        case .today:
            guard let progress = dailyProgress else { return 0 }
            switch focusArea {
            case .eye: return progress.eyeExerciseTime
            case .back: return progress.backExerciseTime
            case .wrist: return progress.wristExerciseTime
            case .wellness: return 0
            }
        case .thisWeek:
            guard let stats = weeklyStats else { return 0 }
            switch focusArea {
            case .eye: return stats.eyeExerciseTime
            case .back: return stats.backExerciseTime
            case .wrist: return stats.wristExerciseTime
            case .wellness: return 0
            }
        }
    }
    
    // MARK: - UI Helpers
    
    func getExercises(for focusArea: FocusArea? = nil, sortedBy: SortOption = .dateAddedNewest) -> [Exercise] {
        var filtered = exercises.values.map { $0 }
        
        if let area = focusArea {
            filtered = filtered.filter { $0.focusArea == area }
        }
        
        switch sortedBy {
        case .dateAddedNewest:
            filtered.sort { $0.addedDate > $1.addedDate }
        case .dateAddedOldest:
            filtered.sort { $0.addedDate < $1.addedDate }
        case .durationLongest:
            filtered.sort { $0.totalDuration > $1.totalDuration }
        case .durationShortest:
            filtered.sort { $0.totalDuration < $1.totalDuration }
        case .alphabeticalAZ:
            filtered.sort { $0.title < $1.title }
        case .alphabeticalZA:
            filtered.sort { $0.title > $1.title }
        case .readTimeHighest, .readTimeLowest:
            break
        }
        
        return filtered
    }
    
    func getArticles(for focusArea: FocusArea? = nil, favoritesOnly: Bool = false, sortedBy: SortOption = .dateAddedNewest) -> [Article] {
        var filtered = articles.values.map { $0 }
        
        if let area = focusArea {
            filtered = filtered.filter { $0.mainTopic == area }
        }
        
        if favoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        switch sortedBy {
        case .dateAddedNewest:
            filtered.sort { $0.addingDate > $1.addingDate }
        case .dateAddedOldest:
            filtered.sort { $0.addingDate < $1.addingDate }
        case .readTimeHighest:
            filtered.sort { $0.readTime > $1.readTime }
        case .readTimeLowest:
            filtered.sort { $0.readTime < $1.readTime }
        case .alphabeticalAZ:
            filtered.sort { $0.title < $1.title }
        case .alphabeticalZA:
            filtered.sort { $0.title > $1.title }
        case .durationLongest, .durationShortest:
            break
        }
        
        return filtered
    }
    
    func getNotifications(includingRead: Bool = false) -> (pending: [AppNotification], completed: [AppNotification]) {
        let allNotifications = notifications.filter { includingRead || !$0.isRead }
        let sortedNotifications = allNotifications.sorted { $0.createdAt > $1.createdAt }
        let pending = sortedNotifications.filter { !$0.isRead }
        let completed = sortedNotifications.filter { $0.isRead }
        return (pending: pending, completed: completed)
    }
    
    func markNotificationAsRead(_ notificationId: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
    }
    
    func getExercise(id: UUID) -> Exercise? {
        return exercises[id]
    }
    
    func getArticle(id: UUID) -> Article? {
        return articles[id]
    }
    
    func toggleFavorite(articleId: UUID) {
        if let index = articles.index(forKey: articleId) {
            articles[articleId]?.isFavorite.toggle()
        }
    }
    
    func markArticleAsRead(articleId: UUID) {
        if let index = articles.index(forKey: articleId) {
            articles[articleId]?.isRead = true
            articles[articleId]?.readByNumOfUsers += 1
            
            if var readArticles = currentUser?.readArticleIds {
                if !readArticles.contains(articleId) {
                    readArticles.append(articleId)
                    currentUser?.readArticleIds = readArticles
                }
            } else {
                currentUser?.readArticleIds = [articleId]
            }
        }
    }
    
    func toggleExerciseInRoutine(exerciseId: UUID, focusArea: FocusArea) {
        guard var routine = userRoutine else {
            if let user = currentUser {
                userRoutine = Routine(id: UUID(), userId: user.id)
                toggleExerciseInRoutine(exerciseId: exerciseId, focusArea: focusArea)
            }
            return
        }
        
        if routine.containsExercise(exerciseId) {
            routine.removeExercise(exerciseId, focusArea: focusArea)
            if let index = exercises.index(forKey: exerciseId) {
                exercises[exerciseId]?.isAddedToRoutine = false
            }
        } else {
            routine.addExercise(exerciseId, focusArea: focusArea)
            if let index = exercises.index(forKey: exerciseId) {
                exercises[exerciseId]?.isAddedToRoutine = true
            }
        }
        
        userRoutine = routine
    }
    
    // MARK: - Sample Data Methods
    
    func loadSampleData() {
        do {
            let sampleUser = try User(
                name: "John Doe",
                email: "john@example.com",
                password: "password123",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
                weekdays: 5,
                numberOfBreaksPreferred: 4,
                breakDuration: 15
            )
            currentUser = sampleUser
            loadUserData()
        } catch {
            print("Failed to create sample user: \(error)")
            currentUser = nil
        }
    }
    
    private func createSampleExercises() -> [Exercise] {
        let eyeExercises: [Exercise] = [
            try! Exercise( // Using try! here since it's sample data and guaranteed valid
                id: UUID(),
                title: "20-20-20 Rule",
                duration: 60,
                description: "Reduce eye strain with a 20-second glance.",
                thumbnailImage: "eye_exercise_1_thumb",
                mainImage: "eye_exercise_1_main",
                reps: nil,
                sets: nil,
                instructions: "Every 20 minutes, stop looking at your screen. Focus on an object 20 feet away for 20 seconds. Relax your shoulders and breathe deeply.",
                focusArea: .eye,
                otherFocusAreas: ["wellness"],
                motivationalTipTitle: "Prevent Digital Eye Strain",
                motivationalContent: "This simple exercise helps prevent Computer Vision Syndrome and keeps your eyes comfortable during long work sessions.",
                commonMistakeContent: "Don't just close your eyes - looking at a distance is what helps your eye muscles relax.",
                info: "The 20-20-20 rule was developed by optometrists specifically for digital device users.",
                whatsInItForYou: "Reduced eye fatigue, fewer headaches, and better focus during work.",
                metValue: 1.0,
                addedDate: Date().addingTimeInterval(-3600 * 24 * 30)
            ),
            try! Exercise(
                id: UUID(),
                title: "Eye Rotations",
                duration: 20,
                description: "Rotate your eyes to improve mobility.",
                thumbnailImage: "eye_exercise_2_thumb",
                mainImage: "eye_exercise_2_main",
                reps: 3,
                sets: 1,
                instructions: "Keep your head still. Slowly rotate your eyes in a clockwise circle. Repeat 3 times. Then rotate counterclockwise 3 times.",
                focusArea: .eye,
                motivationalTipTitle: "Increase Eye Flexibility",
                motivationalContent: "This exercise helps lubricate your eyes and strengthens the eye muscles.",
                metValue: 1.0,
                addedDate: Date().addingTimeInterval(-3600 * 24 * 25)
            )
        ]
        
        let backExercises: [Exercise] = [
            try! Exercise(
                id: UUID(),
                title: "Chair Cat-Cow",
                duration: 30,
                description: "Flex and extend your spine while seated.",
                thumbnailImage: "back_exercise_1_thumb",
                mainImage: "back_exercise_1_main",
                reps: 5,
                sets: 3,
                instructions: "Sit at the edge of your chair. For Cat: round your back, drop your chin to chest. For Cow: arch your back, look up gently. Alternate between positions.",
                focusArea: .back,
                otherFocusAreas: ["wellness"],
                commonMistakeContent: "Don't force the movements - keep them gentle and controlled.",
                whatsInItForYou: "Increased mobility in your spine and relief from back stiffness.",
                metValue: 2.0,
                addedDate: Date().addingTimeInterval(-3600 * 24 * 20)
            ),
            try! Exercise(
                id: UUID(),
                title: "Seated Spinal Twist",
                duration: 30,
                description: "Gently twist your spine to release tension.",
                thumbnailImage: "back_exercise_2_thumb",
                mainImage: "back_exercise_2_main",
                reps: 1,
                sets: 2,
                instructions: "Sit straight. Place right hand on left knee. Place left hand behind you. Gently twist to the left. Hold for 15 seconds. Repeat on other side.",
                focusArea: .back,
                metValue: 1.5,
                addedDate: Date().addingTimeInterval(-3600 * 24 * 15)
            )
        ]
        
        let wristExercises: [Exercise] = [
            try! Exercise(
                id: UUID(),
                title: "Wrist Flexor Stretch",
                duration: 15,
                description: "Stretch the inside of your forearm.",
                thumbnailImage: "wrist_exercise_1_thumb",
                mainImage: "wrist_exercise_1_main",
                reps: 1,
                sets: 2,
                instructions: "Extend arm with palm up. Use other hand to gently pull fingers back toward your body. Hold for 15 seconds. Repeat on other arm.",
                focusArea: .wrist,
                metValue: 1.0,
                addedDate: Date().addingTimeInterval(-3600 * 24 * 10)
            ),
            try! Exercise(
                id: UUID(),
                title: "Wrist Rotations",
                duration: 10,
                description: "Improve wrist mobility with rotations.",
                thumbnailImage: "wrist_exercise_2_thumb",
                mainImage: "wrist_exercise_2_main",
                reps: 10,
                sets: 2,
                instructions: "Extend arms forward. Make a fist. Rotate wrists in circles, 10 times clockwise and 10 times counterclockwise.",
                focusArea: .wrist,
                metValue: 1.0,
                addedDate: Date().addingTimeInterval(-3600 * 24 * 5)
            )
        ]
        
        return eyeExercises + backExercises + wristExercises
    }
    /// Create sample articles data
    private func createSampleArticles() -> [Article] {
        do {
            return [
                try Article(
                    id: UUID(),
                    title: "Home Remedies for Healthy Eyes",
                    author: "Tom Kane",
                    readTime: 4,
                    mainTopic: .eye,
                    additionalTopics: ["wellness"],
                    thumbnailImage: "eye_article_1_thumb",
                    mainImage: "eye_article_1_main",
                    addingDate: Date().addingTimeInterval(-3600 * 24 * 15), // 15 days ago
                    readByNumOfUsers: 142,
                    description: "Guide to Home Remedies for Optimal Eye Care",
                    content: """
                With the increasing emphasis on social media and screen usage, taking care of our eyes has become more important than ever. While professional eye care is essential, incorporating simple home remedies can help maintain healthy vision and prevent strain.
                
                Using a cold compress by placing a cool, damp cloth over closed eyes for 10–15 minutes can reduce puffiness and refresh tired eyes, while a warm compress can help unblock tear ducts and relieve dryness.
                
                Regular eye exercises, such as palming, figure eights, and rotations, can improve focus and reduce eye strain. Staying hydrated by drinking at least eight glasses of water daily is crucial for maintaining proper tear production and preventing dry eyes.
                
                Adequate sleep allows your eyes to rest and repair, so aim for 7-8 hours nightly. Foods rich in vitamins A, C, E, and zinc, like carrots, citrus fruits, nuts, and leafy greens, support eye health from within.
                
                Remember to follow the 20-20-20 rule when using digital devices: every 20 minutes, look at something 20 feet away for 20 seconds to reduce digital eye strain.
                """
                ),
                try Article(
                    id: UUID(),
                    title: "Sit Right, Feel Better: Office Ergonomics",
                    author: "Aayish Khan",
                    readTime: 5,
                    mainTopic: .back,
                    thumbnailImage: "back_article_1_thumb",
                    mainImage: "back_article_1_main",
                    addingDate: Date().addingTimeInterval(-3600 * 24 * 10), // 10 days ago
                    readByNumOfUsers: 87,
                    description: "Learn proper sitting posture to prevent back pain",
                    content: """
                Poor posture during long work hours is a leading cause of back pain among office workers. The good news is that making a few simple adjustments to your workspace can significantly reduce strain on your spine.
                
                Your chair should support the natural curve of your lower back, with your feet flat on the floor and knees at approximately a 90-degree angle. The top of your monitor should be at or slightly below eye level, about an arm's length away.
                
                Your keyboard and mouse should be positioned so your elbows can rest comfortably at your sides, bent at roughly 90 degrees. Use a headset for long calls instead of cradling the phone between your ear and shoulder.
                
                Even with perfect ergonomics, sitting for extended periods is harmful. Set a timer to stand and stretch every 30 minutes, even if just for a minute. Consider a sit-stand desk if possible.
                
                Remember that strengthening your core muscles through regular exercise provides internal support for your spine, complementing your ergonomic setup.
                """
                ),
                try Article(
                    id: UUID(),
                    title: "5 Essential Stretches for Healthy Wrists",
                    author: "Grey top Warriors",
                    readTime: 3,
                    mainTopic: .wrist,
                    thumbnailImage: "wrist_article_1_thumb",
                    mainImage: "wrist_article_1_main",
                    addingDate: Date().addingTimeInterval(-3600 * 24 * 5), // 5 days ago
                    readByNumOfUsers: 53,
                    description: "Prevent carpal tunnel with these simple stretches",
                    content:                 """
                If you type, swipe, or tap all day, your wrists are working overtime. These five essential stretches can help prevent repetitive strain injuries like carpal tunnel syndrome.
                
                1. Wrist Flexor Stretch: Extend one arm with palm up. Gently pull fingers back toward your body with your other hand. Hold for 15-30 seconds, then switch arms.
                
                2. Wrist Extensor Stretch: Extend one arm with palm down. Gently press down on the hand with your other hand. Hold for 15-30 seconds, then switch arms.
                
                3. Prayer Stretch: Place palms together in front of your chest in a prayer position. Slowly lower your hands until you feel a stretch. Hold for 15 seconds.
                
                4. Finger Fans: Start with fingers together, then spread them apart as far as possible. Hold for 5 seconds, then relax. Repeat 10 times.
                
                5. Wrist Circles: Extend arms forward, make loose fists, and circle wrists 10 times in each direction.
                
                Perform these stretches at least twice daily, especially before long periods of typing or smartphone use. If you experience pain (not just stretching sensation), stop immediately and consult a healthcare provider.
                """
                )
            ]
        }catch {
            print("Failed to create sample articles: \(error)")
            return [] // Return empty array as fallback
        }
    }
}
