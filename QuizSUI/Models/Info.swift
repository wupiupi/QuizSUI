//
//  Info.swift
//  QuizSUI
//
//  Created by Paul Makey on 5.05.24.
//

import Foundation

// MARK: - Quiz Info Codable Model
struct Info: Codable {
    var title: String
    var peopleAttended: Int
    var rules: [String]
    
    enum CodingKeys: CodingKey {
        case title
        case peopleAttended
        case rules
    }
}
