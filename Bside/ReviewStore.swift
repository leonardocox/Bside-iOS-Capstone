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

    static func review(for musicItem: MusicItem) throws -> MusicReview? {
        try load().first { saved in
            if musicItem.isAlbum {
                guard let id = musicItem.collectionId else { return false }
                return saved.musicItem.isAlbum &&
                    saved.musicItem.collectionId == id
            } else {
                guard let id = musicItem.trackId else { return false }
                return !saved.musicItem.isAlbum &&
                    saved.musicItem.trackId == id
            }
        }
    }

    static func save(_ review: MusicReview) throws {
        var reviews = try load()

        if let index = reviews.firstIndex(where: { $0.id == review.id }) {
            reviews[index] = review
        } else if let existing = try self.review(for: review.musicItem),
                  let index = reviews.firstIndex(where: { $0.id == existing.id }) {
            reviews[index] = MusicReview(
                id: existing.id,
                musicItem: review.musicItem,
                firstListen: review.firstListen,
                liked: review.liked,
                rating: review.rating,
                reviewText: review.reviewText,
                createdAt: existing.createdAt
            )
        } else {
            reviews.insert(review, at: 0)
        }

        let data = try JSONEncoder().encode(reviews)
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func delete(id: UUID) throws {
        var reviews = try load()
        reviews.removeAll { $0.id == id }

        let data = try JSONEncoder().encode(reviews)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
