//
//  RefreshXApp.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import SwiftUI

@main
struct RefreshXApp: App {
    // Create a single instance of the DataManager to share across the app
    @StateObject private var dataManager = DataManager.shared
    
    // Handle app lifecycle events
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .preferredColorScheme(dataManager.userSettings?.darkModeEnabled == true ? .dark : nil)
                .onAppear {
                    // Setup any required app configuration here
                    print("App launched")
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("App became active")
                // Handle app coming to foreground
                // For example, refresh data or check for pending notifications
            case .inactive:
                print("App became inactive")
                // Handle transitional state
            case .background:
                print("App entered background")
                // Save any pending changes when app goes to background
            @unknown default:
                print("Unknown scene phase")
            }
        }
    }
}
