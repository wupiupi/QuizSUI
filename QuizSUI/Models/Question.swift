//
//  Question.swift
//  QuizSUI
//
//  Created by Paul Makey on 5.05.24.
//

import Foundation

// MARK: - Quiz Question Codable Model
struct Question: Identifiable, Codable {
    var id = UUID()
    var question: String
    var options: [String]
    var answer: String
    
    /// - For UI State Updates
    var tappedAnswer = ""
    
    enum CodingKeys: CodingKey {
        case question
        case options
        case answer
    }
}
