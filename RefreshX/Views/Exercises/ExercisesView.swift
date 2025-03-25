//
//  ExercisesView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//


import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            Text("Exercises Screen - Coming Soon")
                .navigationTitle("Exercises")
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
            .environmentObject(DataManager.shared)
    }
}
