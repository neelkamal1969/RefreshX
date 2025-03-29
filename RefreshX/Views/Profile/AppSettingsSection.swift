//
//  AppSettingsSection.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//
import SwiftUI

struct AppSettingsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showEditView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text("App Settings")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryText"))
                
                Spacer()
                
                Button(action: {
                    showEditView = true
                }) {
                    Text("Edit")
                        .font(.subheadline)
                        .foregroundColor(Color("AccentColor"))
                }
            }
            
            Divider()
            
            if let settings = dataManager.userSettings {
                // Notifications
                SettingRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    value: settings.notificationsEnabled ? "Enabled" : "Disabled"
                )
                
                // Break Reminders
                SettingRow(
                    icon: "timer",
                    title: "Break Reminders",
                    value: settings.breakRemindersEnabled ? "Enabled" : "Disabled"
                )
                
                // Sound
                SettingRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound",
                    value: settings.soundEnabled ? "Enabled" : "Disabled"
                )
                
                // Appearance
                SettingRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    value: settings.darkModeEnabled ? "Enabled" : "Disabled"
                )
                
                // Health Info
                if let weight = settings.userWeight, let height = settings.userHeight {
                    SettingRow(
                        icon: "heart.fill",
                        title: "Weight & Height",
                        value: "\(Int(weight)) kg, \(Int(height)) cm"
                    )
                    
                    if let bmi = settings.bmi, let category = settings.bmiCategory {
                        SettingRow(
                            icon: "chart.bar.fill",
                            title: "BMI",
                            value: String(format: "%.1f", bmi) + " (\(category))"
                        )
                    }
                }
                
                // Reminder time
                SettingRow(
                    icon: "clock.fill",
                    title: "Remind Before",
                    value: "\(settings.remindersBefore) minutes"
                )
            } else {
                Text("Settings not available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 10)
            }
        }
        .padding()
        .background(Color("FieldBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showEditView) {
            if let settings = dataManager.userSettings, let user = dataManager.currentUser {
                EditSettingsView(settings: settings, userId: user.id)
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("AccentColor"))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
