//
//  ProfileView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = dataManager.currentUser {
                        // Profile Header
                        ProfileHeaderView(user: user)
                            .padding(.bottom, 10)
                        
                        // Content Sections
                        VStack(spacing: 16) {
                            PersonalInfoSection(user: user)
                                .environmentObject(dataManager)
                            
                            BreakScheduleSection(user: user)
                                .environmentObject(dataManager)
                            
                            AppSettingsSection()
                            
                            AppInfoSection()
                            
                            AccountActionsSection(
                                onSignOut: { showSignOutAlert = true },
                                onDeleteAccount: { showDeleteAccountAlert = true }
                            )
                        }
                        .padding(.horizontal)
                    } else {
                        Text("User not found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Profile")
            .background(Color("PrimaryBackground").ignoresSafeArea())
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    dataManager.clearCurrentUser()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                
                Button("Delete Account", role: .destructive) {
                    // In a real app with Supabase, you would call the API here:
                    // supabase.from("users").delete().eq("id", user.id)
                    //     .execute { result in
                    //         // Handle the result
                    //     }
                    
                    // Immediately log the user out without showing progress
                    dataManager.clearCurrentUser()
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
            .onAppear {
                // Sync theme on view appear - this ensures UI is updated when returning to profile
                if let settings = dataManager.userSettings {
                    ThemeManager.shared.syncWithUserSettings(settings)
                }
            }
        }
        .preferredColorScheme(dataManager.userSettings?.darkModeEnabled == true ? .dark : .light)
    }
}
