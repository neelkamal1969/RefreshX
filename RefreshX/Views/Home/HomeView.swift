//
//  HomeView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            Text("Home Screen - Coming Soon")
                .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(DataManager.shared)
    }
}
