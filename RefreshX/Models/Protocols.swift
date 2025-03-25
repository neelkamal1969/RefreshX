//
//  Protocols.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//


import Foundation

    // MARK: - Protocols

    /// Protocol for objects that can be tracked
protocol Trackable {
    var id: UUID { get }
    var lastUpdated: Date { get set }
}

    /// Protocol for objects that belong to exercises
protocol ExerciseRelated {
    var focusArea: FocusArea { get }
}
