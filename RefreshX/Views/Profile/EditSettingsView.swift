
//
//  EditSettingsView.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//

import SwiftUI
import Combine

struct EditSettingsView: View {
    let settings: UserSettings
    let userId: UUID
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    // MARK: - State Variables
    @State private var notificationsEnabled: Bool
    @State private var breakRemindersEnabled: Bool
    @State private var exerciseRemindersEnabled: Bool
    @State private var soundEnabled: Bool
    @State private var autoStartBreaksEnabled: Bool
    @State private var darkModeEnabled: Bool
    @State private var userWeight: Double?
    @State private var userHeight: Double?
    @State private var remindersBefore: Int
    @State private var readAloudEnabled: Bool
    @State private var largeTextEnabled: Bool
    
    @State private var weightString: String = ""
    @State private var heightString: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    
    // MARK: - Initialization
    
    init(settings: UserSettings, userId: UUID) {
        self.settings = settings
        self.userId = userId
        
        // Initialize state variables from settings
        _notificationsEnabled = State(initialValue: settings.notificationsEnabled)
        _breakRemindersEnabled = State(initialValue: settings.breakRemindersEnabled)
        _exerciseRemindersEnabled = State(initialValue: settings.exerciseRemindersEnabled)
        _soundEnabled = State(initialValue: settings.soundEnabled)
        _autoStartBreaksEnabled = State(initialValue: settings.autoStartBreaksEnabled)
        _darkModeEnabled = State(initialValue: settings.darkModeEnabled)
        _userWeight = State(initialValue: settings.userWeight)
        _userHeight = State(initialValue: settings.userHeight)
        _remindersBefore = State(initialValue: settings.remindersBefore)
        _readAloudEnabled = State(initialValue: settings.readAloudEnabled)
        _largeTextEnabled = State(initialValue: settings.largeTextEnabled)
        
        // Initialize string versions of numeric fields
        _weightString = State(initialValue: settings.userWeight != nil ? String(format: "%.1f", settings.userWeight!) : "")
        _heightString = State(initialValue: settings.userHeight != nil ? String(format: "%.1f", settings.userHeight!) : "")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .padding(.vertical, 4)
                        .onChange(of: notificationsEnabled) { oldValue,newValue in
                            if !newValue {
                                breakRemindersEnabled = false
                                exerciseRemindersEnabled = false
                            }
                        }
                    
                    if notificationsEnabled {
                        Toggle("Break Reminders", isOn: $breakRemindersEnabled)
                            .padding(.vertical, 4)
                            .disabled(!notificationsEnabled)
                        
                        Toggle("Exercise Reminders", isOn: $exerciseRemindersEnabled)
                            .padding(.vertical, 4)
                            .disabled(!notificationsEnabled)
                        
                        VStack(alignment: .leading) {
                            Text("Remind Before Break")
                                .font(.subheadline)
                            
                            HStack {
                                Slider(value: Binding(
                                    get: { Double(remindersBefore) },
                                    set: { remindersBefore = Int($0) }
                                ), in: 1...30, step: 1)
                                .accentColor(Color("AccentColor"))
                                
                                Text("\(remindersBefore) min")
                                    .frame(width: 60)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .disabled(!notificationsEnabled)
                    }
                }
                
                // MARK: - Preferences Section
                Section(header: Text("Preferences")) {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                        .padding(.vertical, 4)
                    
                    Toggle("Auto-Start Breaks", isOn: $autoStartBreaksEnabled)
                        .padding(.vertical, 4)
                    
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .padding(.vertical, 4)
                    
                    Toggle("Read Aloud", isOn: $readAloudEnabled)
                        .padding(.vertical, 4)
                    
                    Toggle("Large Text", isOn: $largeTextEnabled)
                        .padding(.vertical, 4)
                }
                
                // MARK: - Health Information Section
                Section(header: Text("Health Information")) {
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("Weight", text: $weightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: weightString) { oldValue,newValue in
                                if let weight = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                    userWeight = weight
                                } else if newValue.isEmpty {
                                    userWeight = nil
                                }
                            }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("Height", text: $heightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: heightString) { oldValue,newValue in
                                if let height = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                    userHeight = height
                                } else if newValue.isEmpty {
                                    userHeight = nil
                                }
                            }
                    }
                    .padding(.vertical, 4)
                    
                    
                    // Display BMI if both weight and height are provided
                    if let bmiValue = calculateBMI() {
                        let category = getBMICategory(bmiValue)
                        
                        HStack {
                            Text("BMI")
                            Spacer()
                            Text(String(format: "%.1f", bmiValue))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(category)
                                .foregroundColor(getBMIColor(category))
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // MARK: - Validation Error Sections
            
                if userWeight != nil && userWeight! < 20 && !weightString.isEmpty {
                    Section {
                        Text("Weight must be at least 20 kg")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                if userHeight != nil && userHeight! < 50 && !heightString.isEmpty {
                    Section {
                        Text("Height must be at least 50 cm")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Success message
                if showSuccessMessage {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(successMessage)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Edit Settings")
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
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        // Weight validation (only if provided)
        if let weight = userWeight, weight < 20 {
            return false
        }
        
        // Height validation (only if provided)
        if let height = userHeight, height < 50 {
            return false
        }
        
        // Reminder time validation
        if remindersBefore < 1 || remindersBefore > 30 {
            return false
        }
        
        return true
    }
    
    private func calculateBMI() -> Double? {
        guard let weight = userWeight, let height = userHeight, height > 0 else { return nil }
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    private func getBMICategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case ..<25: return "Normal"
        case ..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    private func getBMIColor(_ category: String) -> Color {
        switch category {
        case "Underweight": return .orange
        case "Normal": return .green
        case "Overweight": return .orange
        case "Obese": return .red
        default: return .secondary
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func saveChanges() {
        // Validate form
        guard isFormValid else {
            errorMessage = "Please ensure all fields are valid"
            showAlert = true
            return
        }
        
        // Set loading state but don't show overlay
        isLoading = true
        
        // Immediately create and apply settings
        do {
            let updatedSettings = try UserSettings(
                id: settings.id,
                userId: userId,
                notificationsEnabled: notificationsEnabled,
                breakRemindersEnabled: breakRemindersEnabled,
                exerciseRemindersEnabled: exerciseRemindersEnabled,
                soundEnabled: soundEnabled,
                autoStartBreaksEnabled: autoStartBreaksEnabled,
                darkModeEnabled: darkModeEnabled,
                userWeight: userWeight,
                userHeight: userHeight,
                remindersBefore: remindersBefore,
                readAloudEnabled: readAloudEnabled,
                largeTextEnabled: largeTextEnabled,
                lastUpdated: Date()
            )
            
            // Update settings in DataManager
            dataManager.updateUserSettings(updatedSettings)
            
            // Apply theme changes
            ThemeManager.shared.syncWithUserSettings(updatedSettings)
            
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
// MARK: - Preview
struct EditSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager.shared
        dataManager.loadSampleData()
        
        return Group {
            if let settings = dataManager.userSettings, let user = dataManager.currentUser {
                EditSettingsView(settings: settings, userId: user.id)
                    .environmentObject(dataManager)
            }
        }
    }
}
