//
//  EditBreakScheduleView.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//

import SwiftUI

struct EditBreakScheduleView: View {
    // MARK: - Properties
    let user: User
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    // MARK: - State Variables
    @State var weekdays: Int
    @State var jobStartTime: Date
    @State var jobEndTime: Date
    @State var numberOfBreaksPreferred: Int
    @State var breakDuration: Int
    @State var isLoading = false
    @State var errorMessage: String?
    @State var showAlert = false
    
    // MARK: - Validation States
    @State var timeIsValid = true
    @State var weekdaysIsValid = true
    @State var numberOfBreaksIsValid = true
    @State var breakDurationIsValid = true
    
    // MARK: - Computed Properties
    
    /// Calculated recommended duration based on work hours and number of breaks
    var recommendedDuration: Int {
        guard numberOfBreaksPreferred > 0 else { return User.defaultBreakDuration }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: jobStartTime, to: jobEndTime)
        let workMinutes = max(0, (components.hour ?? 0) * 60 + (components.minute ?? 0))
        let totalBreakTime = Int(Double(workMinutes) * User.breakTimeRatio)
        let recommendedDuration = totalBreakTime / numberOfBreaksPreferred
        
        return min(max(recommendedDuration, User.minBreakDuration), User.maxBreakDuration)
    }
    
    /// Total working hours as formatted string
    var workingHoursFormatted: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: jobStartTime, to: jobEndTime)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let totalMinutes = hours * 60 + minutes
        let totalHours = Double(totalMinutes) / 60.0
        
        return String(format: "%.1f hours", totalHours)
    }
    
    /// Total break time in minutes
    var totalBreakTime: Int {
        return numberOfBreaksPreferred * breakDuration
    }
    
    /// Break time as percentage of work day
    var breakTimePercentage: Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: jobStartTime, to: jobEndTime)
        let workMinutes = max(1, (components.hour ?? 0) * 60 + (components.minute ?? 0))
        
        return (Double(totalBreakTime) / Double(workMinutes)) * 100
    }
    
    /// Color for break percentage
    func breakPercentageColor(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<10: return .orange // Too few breaks
        case 10..<25: return .green // Ideal range
        case 25...: return .red // Too many breaks
        default: return .secondary
        }
    }
    
    /// Check if the form is valid for submission
    var isFormValid: Bool {
        timeIsValid && weekdaysIsValid &&
        numberOfBreaksIsValid && breakDurationIsValid
    }
    
    // MARK: - Initialize the state from the user
    init(user: User) {
        self.user = user
        _weekdays = State(initialValue: user.weekdays)
        _jobStartTime = State(initialValue: user.jobStartTime)
        _jobEndTime = State(initialValue: user.jobEndTime)
        _numberOfBreaksPreferred = State(initialValue: user.numberOfBreaksPreferred)
        _breakDuration = State(initialValue: user.breakDuration)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Work Schedule Section
                Section(header: Text("Work Schedule")) {
                    // Weekdays Picker
                    VStack(alignment: .leading) {
                        Text("Work Days Per Week")
                            .font(.subheadline)
                        
                        Picker("Weekdays", selection: $weekdays) {
                            ForEach(1...7, id: \.self) { num in
                                Text("\(num) day\(num > 1 ? "s" : "")")
                                    .tag(num)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 4)
                        .onChange(of: weekdays) { oldValue, newValue in
                            weekdaysIsValid = newValue >= 1 && newValue <= 7
                        }
                    }
                    
                    // Work Hours
                    VStack(alignment: .leading, spacing: 4) {
                        // Start Time
                        DatePicker("Start Time", selection: $jobStartTime, displayedComponents: .hourAndMinute)
                            .padding(.vertical, 4)
                            .onChange(of: jobStartTime) { oldValue, newValue in
                                validateTimes()
                            }
                        
                        // End Time
                        DatePicker("End Time", selection: $jobEndTime, displayedComponents: .hourAndMinute)
                            .padding(.vertical, 4)
                            .onChange(of: jobEndTime) { oldValue, newValue in
                                validateTimes()
                            }
                            
                        // Show error if times are invalid
                        if !timeIsValid {
                            Text("End time must be after start time")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Show working hours summary
                    if timeIsValid {
                        HStack {
                            Text("Total Working Hours")
                            Spacer()
                            Text(workingHoursFormatted)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // MARK: - Break Preferences Section
                Section(header: Text("Break Preferences")) {
                    // Number of Breaks
                    VStack(alignment: .leading) {
                        Text("Number of Breaks")
                            .font(.subheadline)
                        
                        Stepper("\(numberOfBreaksPreferred) break\(numberOfBreaksPreferred > 1 ? "s" : "") per day", value: $numberOfBreaksPreferred, in: 1...10)
                            .padding(.vertical, 4)
                            .onChange(of: numberOfBreaksPreferred) { oldValue, newValue in
                                numberOfBreaksIsValid = newValue >= 1
                            }
                    }
                    
                    // Break Duration
                    VStack(alignment: .leading) {
                        Text("Break Duration")
                            .font(.subheadline)
                        
                        HStack {
                            Slider(value: Binding(
                                get: { Double(breakDuration) },
                                set: { breakDuration = Int($0) - (Int($0) % 5) }
                            ), in: 5...60, step: 5)
                            .accentColor(Color("AccentColor"))
                            
                            Text("\(breakDuration) min")
                                .frame(width: 60)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .onChange(of: breakDuration) { oldValue, newValue in
                            breakDurationIsValid = newValue >= 5 && newValue <= 60
                        }
                    }
                    
                    // Recommended Duration
                    HStack {
                        Text("Recommended Duration")
                        Spacer()
                        Text("\(recommendedDuration) min")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    // Use Recommended Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            breakDuration = recommendedDuration
                        }
                    }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Use Recommended")
                        }
                    }
                    .foregroundColor(Color("AccentColor"))
                }
                
                // MARK: - Break time calculation
                Section(header: Text("Summary")) {
                    // Total Break Time
                    HStack {
                        Text("Total Break Time")
                        Spacer()
                        Text("\(totalBreakTime) minutes")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                    
                    // Break Time Percentage
                    if timeIsValid {
                        HStack {
                            Text("Percentage of Work Day")
                            Spacer()
                            Text(String(format: "%.1f%%", breakTimePercentage))
                                .foregroundColor(breakPercentageColor(breakTimePercentage))
                        }
                        .padding(.vertical, 2)
                    }
                    
                    // Break distribution visualization
                    if timeIsValid && numberOfBreaksPreferred > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Break Distribution")
                                .font(.subheadline)
                            
                            BreakDistributionView(
                                startTime: jobStartTime,
                                endTime: jobEndTime,
                                numberOfBreaks: numberOfBreaksPreferred
                            )
                            .frame(height: 50)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Edit Break Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveChanges) {
                        Text("Save")
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                validateTimes()
                validateOtherFields()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Validate time fields
    func validateTimes() {
        timeIsValid = jobStartTime < jobEndTime
        
        // If times are invalid, attempt to fix by adding hours to end time
        if !timeIsValid {
            // Get hour components
            let calendar = Calendar.current
            var endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: jobEndTime)
            let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: jobStartTime)
            
            // If end hour <= start hour, add 8 hours to end time
            if let endHour = endComponents.hour, let startHour = startComponents.hour, endHour <= startHour {
                endComponents.hour = startHour + 8
                if let newEndTime = calendar.date(from: endComponents) {
                    jobEndTime = newEndTime
                    timeIsValid = true
                }
            }
        }
    }
    
    /// Validate other form fields
    func validateOtherFields() {
        weekdaysIsValid = weekdays >= 1 && weekdays <= 7
        numberOfBreaksIsValid = numberOfBreaksPreferred >= 1
        breakDurationIsValid = breakDuration >= 5 && breakDuration <= 60
    }
    
    /// Save changes to the break schedule
    func saveChanges() {
        guard isFormValid else {
            errorMessage = "Please ensure all fields are valid"
            showAlert = true
            return
        }
        
        // Set loading state but don't show overlay
        isLoading = true
        
        do {
            // Update break schedule with validation
            try dataManager.updateBreakSchedule(
                weekdays: weekdays,
                startTime: jobStartTime,
                endTime: jobEndTime,
                numberOfBreaks: numberOfBreaksPreferred,
                breakDuration: breakDuration
            )
            
            // Dismiss immediately
            dismiss()
            
        } catch {
            // Handle validation errors
            isLoading = false
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}

// MARK: - Break Distribution View
struct BreakDistributionView: View {
    let startTime: Date
    let endTime: Date
    let numberOfBreaks: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                
                // Calculate break positions
                let workDuration = endTime.timeIntervalSince(startTime)
                let breakInterval = workDuration / Double(numberOfBreaks + 1)
                
                // Draw breaks
                ForEach(1...numberOfBreaks, id: \.self) { breakIndex in
                    let breakPosition = (Double(breakIndex) * breakInterval) / workDuration
                    let xPos = geometry.size.width * CGFloat(breakPosition)
                    
                    Rectangle()
                        .fill(Color("AccentColor"))
                        .frame(width: 4, height: geometry.size.height)
                        .position(x: xPos, y: geometry.size.height / 2)
                }
                
                // Start and end labels
                HStack {
                    Text(formatTime(startTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(endTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}
