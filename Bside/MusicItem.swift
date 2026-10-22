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

    var title: String {
        trackName ?? collectionName ?? "Unknown title"
    }

    var isAlbum: Bool {
        wrapperType == "collection"
    }
}
