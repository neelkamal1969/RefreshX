//
//  ExploreView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//
import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Explore Screen - Coming Soon")
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
            }
            .navigationTitle("Explore")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("PrimaryBackground"))
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(DataManager.shared)
    }
}
