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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
