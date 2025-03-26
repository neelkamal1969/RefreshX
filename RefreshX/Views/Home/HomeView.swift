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
            VStack {
                Text("Home Screen - Coming Soon")
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
            }
            .navigationTitle("Home")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("PrimaryBackground"))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(DataManager.shared)
    }
}
