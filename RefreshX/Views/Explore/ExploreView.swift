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
            Text("Explore Screen - Coming Soon")
                .navigationTitle("Explore")
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(DataManager.shared)
    }
}
