//
//  RefreshXApp.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//
import SwiftUI

@main
struct RefreshXApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .preferredColorScheme(dataManager.userSettings?.darkModeEnabled == true ? .dark : .light)
                .onAppear {
                    print("App launched")
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("App became active")
            case .inactive:
                print("App became inactive")
            case .background:
                print("App entered background")
            @unknown default:
                print("Unknown scene phase")
            }
        }
    }
}
