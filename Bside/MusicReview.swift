//
//  MusicReview.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 11/2/26.
//

import Foundation

import Foundation

struct MusicReview: Codable {
    let id: UUID
    let musicItem: MusicItem
    let firstListen: Bool
    let liked: Bool
    let rating: Double
    let reviewText: String
    let createdAt: Date
}
