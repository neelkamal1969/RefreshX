//
//  ProfileView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            Text("Profile Screen - Coming Soon")
                .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(DataManager.shared)
    }
}
