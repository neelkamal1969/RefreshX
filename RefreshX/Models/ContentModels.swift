//
//  ContentModels.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//


import Foundation
struct Article: Identifiable, Codable, ExerciseRelated {
    let id: UUID
    var title: String
    var author: String
    var readTime: Int
    var mainTopic: FocusArea
    var additionalTopics: [String]?
    var thumbnailImage: String
    var mainImage: String
    var addingDate: Date
    var readByNumOfUsers: Int
    var isRead: Bool
    var isFavorite: Bool
    var supportingLink: String?
    var description: String
    var content: String
    
    init(id: UUID = UUID(), title: String, author: String, readTime: Int, mainTopic: FocusArea, additionalTopics: [String]? = nil, thumbnailImage: String, mainImage: String, addingDate: Date = Date(), readByNumOfUsers: Int = 0, isRead: Bool = false, isFavorite: Bool = false, supportingLink: String? = nil, description: String, content: String) throws {
        guard !title.isEmpty, !author.isEmpty else { throw ValidationError.invalidText }
        guard readTime > 0 else { throw ValidationError.invalidReadTime }
        self.id = id
        self.title = title
        self.author = author
        self.readTime = readTime
        self.mainTopic = mainTopic
        self.additionalTopics = additionalTopics
        self.thumbnailImage = thumbnailImage
        self.mainImage = mainImage
        self.addingDate = addingDate
        self.readByNumOfUsers = readByNumOfUsers
        self.isRead = isRead
        self.isFavorite = isFavorite
        self.supportingLink = supportingLink
        self.description = description
        self.content = content
    }
    
    var isRecent: Bool {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return addingDate > sevenDaysAgo
    }
    
    var contentPreview: String {
        let firstParagraph = content.components(separatedBy: "\n").first ?? ""
        return firstParagraph.count > 100 ? String(firstParagraph.prefix(100)) + "..." : firstParagraph
    }
    
    var focusArea: FocusArea { mainTopic }
    
    enum ValidationError: Error {
        case invalidText
        case invalidReadTime
    }
}

struct AppNotification: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var isRead: Bool
    var title: String
    var message: String
    var type: NotificationType
    var createdAt: Date
    var relatedId: UUID?
    
    init(id: UUID = UUID(), userId: UUID, isRead: Bool = false, title: String, message: String, type: NotificationType, createdAt: Date = Date(), relatedId: UUID? = nil) throws {
        guard !title.isEmpty, !message.isEmpty else { throw ValidationError.invalidText }
        self.id = id
        self.userId = userId
        self.isRead = isRead
        self.title = title
        self.message = message
        self.type = type
        self.createdAt = createdAt
        self.relatedId = relatedId
    }
    
    var isRecent: Bool {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return createdAt > yesterday
    }
    
    enum ValidationError: Error {
        case invalidText
    }
}
