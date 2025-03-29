//
//  ArticleDetailView.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//

import SwiftUI
import AVFoundation

struct ArticleDetailView: View {
    @State var article: Article
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.colorScheme) var colorScheme
    
    // Speech synthesis for read aloud feature
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isReading: Bool = false
    
    // Animation states
    @State private var showControls: Bool = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topTrailing) {
                // Article header image
                if !article.mainImage.isEmpty {  // Removed `if let` since mainImage is not optional
                    Image(article.mainImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.5),
                                    Color.black.opacity(0.0)
                                ]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                }
                
                // Favorite button
                Button(action: toggleFavorite) {
                    Image(systemName: article.isFavorite ? "star.fill" : "star")
                        .foregroundColor(article.isFavorite ? .yellow : .white)
                        .font(.system(size: 24))
                        .padding(12)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
                .offset(y: 10)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                // Article title and metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                            Text(article.author)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text("\(article.readTime) min read")
                                .foregroundColor(.gray)
                        }
                    }
                    .font(.subheadline)
                    
                    HStack(spacing: 8) {
                        // Category pill
                        Text(article.mainTopic.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(categoryColor(for: article.mainTopic).opacity(0.2))
                            .foregroundColor(categoryColor(for: article.mainTopic))
                            .cornerRadius(16)
                        
                        // Additional topics
                        ForEach(article.additionalTopics ?? [], id: \.self) { topic in
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.gray)
                                .cornerRadius(16)
                        }
                    }
                }
                
                Divider()
                
                // Article content
                VStack(alignment: .leading, spacing: 16) {
                    Text(article.content)
                        .font(.body)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .onAppear {
                            // Mark as read when viewed
                            if !article.isRead {
                                dataManager.markArticleAsRead(articleId: article.id)
                                article.isRead = true
                            }
                        }
                }
                
                Divider()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Logic to open full article in web view or similar
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Read Full Article")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        dataManager.markArticleAsRead(articleId: article.id)
                        article.isRead = true
                    }) {
                        HStack {
                            Image(systemName: article.isRead ? "checkmark.circle.fill" : "circle")
                            Text(article.isRead ? "Marked as Read" : "Mark as Read")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    Button(action: toggleReadAloud) {
                        HStack {
                            Image(systemName: isReading ? "pause.fill" : "play.fill")
                            Text(isReading ? "Stop Listening" : "Listen to Article")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .ignoresSafeArea(.all, edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: article.isFavorite ? "star.fill" : "star")
                        .foregroundColor(article.isFavorite ? .yellow : Color("AccentColor"))
                }
            }
        }
        .onDisappear {
            // Stop reading if user leaves the view
            if isReading {
                synthesizer.stopSpeaking(at: .immediate)
                isReading = false
            }
        }
    }
    
    private func toggleFavorite() {
        dataManager.toggleFavorite(articleId: article.id)
        article.isFavorite.toggle()
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func toggleReadAloud() {
        if isReading {
            synthesizer.stopSpeaking(at: .immediate)
            isReading = false
        } else {
            let utterance = AVSpeechUtterance(string: article.content)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            synthesizer.speak(utterance)
            isReading = true
        }
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
