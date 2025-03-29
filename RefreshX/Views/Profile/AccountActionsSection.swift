//
//  AccountActionsSection.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//
import SwiftUI

struct AccountActionsSection: View {
    var onSignOut: () -> Void
    var onDeleteAccount: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onSignOut) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Sign Out")
                        .fontWeight(.medium)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            
            Button(action: onDeleteAccount) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Account")
                        .fontWeight(.medium)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color("FieldBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
