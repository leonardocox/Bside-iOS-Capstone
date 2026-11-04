//
//  MusicItem.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/22/26.
//

import Foundation

struct MusicSearchResponse: Decodable {
    let results: [MusicItem]
}

struct MusicItem: Codable {
    let wrapperType: String
    let kind: String?
    let trackId: Int?
    let collectionId: Int?
    let trackName: String?
    let collectionName: String?
    let artistName: String
    let artworkUrl100: URL?
    let trackViewUrl: URL?
    let collectionViewUrl: URL?
    let previewUrl: URL?
    
    var detailArtworkURL: URL? {
        guard let artworkUrl100 else { return nil }
        let largerURL = artworkUrl100.absoluteString.replacingOccurrences(
            of: "/100x100bb.jpg",
            with: "/600x600bb.jpg"
        )
        return URL(string: largerURL) ?? artworkUrl100
    }

    var title: String {
        trackName ?? collectionName ?? "Unknown title"
    }

    var isAlbum: Bool {
        wrapperType == "collection"
    }
}
