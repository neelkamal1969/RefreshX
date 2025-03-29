//
//  EmptyStateView.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//

// EmptyStateView.swift

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(Color.gray.opacity(0.7))
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text(title)
                .font(.headline)
                .foregroundColor(Color("PrimaryText"))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("FieldBackground").opacity(0.5))
        .cornerRadius(12)
        .onAppear {
            isAnimating = true
        }
    }
}
