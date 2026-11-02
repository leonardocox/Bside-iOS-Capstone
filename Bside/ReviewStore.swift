//
//  ReviewStore.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 11/2/26.
//

import Foundation

enum ReviewStore {
    private static let storageKey = "savedMusicReviews"

    static func load() throws -> [MusicReview] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }

        return try JSONDecoder().decode([MusicReview].self, from: data)
    }

    static func add(_ review: MusicReview) throws {
        var reviews = try load()
        reviews.insert(review, at: 0)

        let data = try JSONEncoder().encode(reviews)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
