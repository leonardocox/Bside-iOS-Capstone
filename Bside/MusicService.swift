//
//  MusicService.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/22/26.
//

import Foundation

// The iTunes search can return either songs or albums.
// The raw value becomes the "entity" value in the request URL.
enum MusicSearchType: String {
    case song
    case album
}

// Handles the catalog request so the Discover screen can focus on displaying results.
final class MusicService {

    // Searches Apple's catalog and returns either music items or an error.
    // The completion closure runs when the network request finishes.
    func search(
        for term: String,
        type: MusicSearchType,
        completion: @escaping (Result<[MusicItem], Error>) -> Void
    ) {
        // URLComponents safely adds the search term and other query values to the URL.
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: type.rawValue),
            URLQueryItem(name: "country", value: "US"),
            URLQueryItem(name: "limit", value: "25")
        ]

        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // This is the same URLSession request pattern used in earlier API projects.
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Continue only when the server responded successfully and sent data.
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    // Convert the JSON into the models in MusicItem.swift.
                    let searchResponse = try JSONDecoder().decode(
                        MusicSearchResponse.self,
                        from: data
                    )
                    completion(.success(searchResponse.results))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
