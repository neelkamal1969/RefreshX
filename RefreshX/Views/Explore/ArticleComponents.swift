//
//  ArticleComponents.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//

import SwiftUI

// Component for article items in list views
struct ArticleListItem: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Article image
            if !article.thumbnailImage.isEmpty {  // Removed `if let` since thumbnailImage is not optional
                Image(article.thumbnailImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
            }
            
            // Article details
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(Color("PrimaryText"))
                
                HStack {
                    Text(article.author)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(article.readTime) min read")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        // Category indicator
                        Text(article.mainTopic.rawValue)
                            .font(.caption)
                            .foregroundColor(categoryColor(for: article.mainTopic))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(categoryColor(for: article.mainTopic).opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    if article.isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    if article.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func categoryColor(for area: FocusArea) -> Color {
        switch area {
        case .eye:
            return .blue
        case .back:
            return .green
        case .wrist:
            return .orange
        case .wellness:
            return .purple
        }
    }
}

// Card component for horizontal scroll in recommendations
struct RecommendedArticleCard: View {
    let article: Article
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            if !article.thumbnailImage.isEmpty {  // Removed `if let` since thumbnailImage is not optional
                Image(article.thumbnailImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.0)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            
            // Article info
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(article.author)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 12) {
                    Text(article.mainTopic.rawValue)
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text("\(article.readTime) min")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(12)
        }
        .cornerRadius(16)
        .shadow(radius: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("AccentColor").opacity(0.2), lineWidth: 1)
        )
    }
}
