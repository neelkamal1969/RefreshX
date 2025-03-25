//
//  ProgressView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            Text("Progress Screen - Coming Soon")
                .navigationTitle("Progress")
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(DataManager.shared)
    }
}
