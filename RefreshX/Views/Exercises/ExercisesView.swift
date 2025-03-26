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
            VStack {
                Text("Exercises Screen - Coming Soon")
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
            }
            .navigationTitle("Exercises")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("PrimaryBackground"))
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
            .environmentObject(DataManager.shared)
    }
}
