//
//  BreakScheduleSection.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//
import SwiftUI

struct BreakScheduleSection: View {
    let user: User
    @State private var showEditView = false
    @EnvironmentObject var dataManager: DataManager  // Add EnvironmentObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text("Break Schedule")
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
            
            // Work days
            SettingRow(
                icon: "calendar",
                title: "Work Days",
                value: "\(user.weekdays) days per week"
            )
            
            // Work hours
            SettingRow(
                icon: "clock",
                title: "Work Hours",
                value: "\(formatTime(user.jobStartTime)) to \(formatTime(user.jobEndTime))"
            )
            
            // Number of breaks
            SettingRow(
                icon: "stopwatch",
                title: "Breaks",
                value: "\(user.numberOfBreaksPreferred) breaks per day"
            )
            
            // Break duration
            SettingRow(
                icon: "timer",
                title: "Duration",
                value: "\(user.breakDuration) minutes each"
            )
            
            // Recommended duration
            SettingRow(
                icon: "wand.and.stars",
                title: "Recommended",
                value: "\(user.recommendedBreakDuration) minutes each"
            )
        }
        .padding()
        .background(Color("FieldBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showEditView) {
            EditBreakScheduleView(user: dataManager.currentUser!) // Use currentUser directly
                .environmentObject(dataManager)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}
