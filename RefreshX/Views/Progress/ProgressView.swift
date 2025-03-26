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
            VStack {
                Text("Progress Screen - Coming Soon")
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
            }
            .navigationTitle("Progress")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("PrimaryBackground"))
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environmentObject(DataManager.shared)
    }
}
