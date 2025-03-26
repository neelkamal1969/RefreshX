//
//  MainTabView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ExercisesView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.walk")
                }
            
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "safari.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(Color("AccentColor")) // Apply system blue as accent
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(DataManager.shared)
    }
}
