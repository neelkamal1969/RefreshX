//
//  ArticleExtensions.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//

// ArticleExtensions.swift

import Foundation
import SwiftUI

extension Article {
    // Get a formatted date string for the article
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: addingDate)
    }
    
    // Get a short preview of the content
    var shortPreview: String {
        let maxLength = 120
        if content.count <= maxLength {
            return content
        }
        
        let end = content.index(content.startIndex, offsetBy: maxLength)
        return String(content[..<end]) + "..."
    }
    
    // Get appropriate icon for the topic
    var topicIcon: String {
        switch mainTopic {
        case .eye:
            return "eye"
        case .back:
            return "figure.walk"
        case .wrist:
            return "hand.raised"
        case .wellness:
            return "heart"
        }
    }
    
    // Get color for the topic
    var topicColor: Color {
        switch mainTopic {
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
