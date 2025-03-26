//
//  ProfileView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Centered placeholder content
                Spacer() // Pushes content to center
                Text("Profile Screen - Coming Soon")
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
                Spacer() // Balances centering
                
                // Logout button at bottom
                Button(action: {
                    showLogoutAlert = true
                }) {
                    Text("Sign Out")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.red) // iOS standard red for destructive actions
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Profile")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("PrimaryBackground"))
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        dataManager.clearCurrentUser() // Corrected method call
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(DataManager.shared)
    }
}
