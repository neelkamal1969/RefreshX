//
//  PersonalInfoSection.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//
import SwiftUI

struct PersonalInfoSection: View {
    let user: User
    @State private var showEditView = false
    @EnvironmentObject var dataManager: DataManager  // Add EnvironmentObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text("Personal Information")
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
            
            // Name
            SettingRow(
                icon: "person.fill",
                title: "Full Name",
                value: user.name
            )
            
            // Email
            SettingRow(
                icon: "envelope.fill",
                title: "Email",
                value: user.email
            )
            
            // Date of Birth
            SettingRow(
                icon: "calendar",
                title: "Date of Birth",
                value: formattedDate(user.dateOfBirth)
            )
            
            // Age
            SettingRow(
                icon: "number",
                title: "Age",
                value: calculateAge(from: user.dateOfBirth)
            )
        }
        .padding()
        .background(Color("FieldBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showEditView) {
            EditPersonalInfoView(user: dataManager.currentUser!) // Use currentUser directly
                .environmentObject(dataManager)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func calculateAge(from date: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return "\(ageComponents.year ?? 0) years"
    }
}
