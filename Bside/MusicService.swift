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
    
    // Fetches the songs for one album using its iTunes collection ID
    // basically is taking an album id, requesting album's songs, removes the album entry from the response, and then hands the song list back via completion
    func tracks(
        for collectionId: Int,
        completion: @escaping (Result<[MusicItem], Error>) -> Void
    ) {
        // Build a lookup URL for this album and ask the API to include songs.
        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        components?.queryItems = [
            URLQueryItem(name: "id", value: String(collectionId)),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "country", value: "US")
        ]

        // Report an error if the URL could not be created.
        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // Start the request. The completion closure runs when the API responds.
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Continue only if the request succeeded and returned data.
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    // Turn the JSON into the MusicItem model we already use.
                    let lookupResponse = try JSONDecoder().decode(
                        MusicSearchResponse.self,
                        from: data
                    )

                    // The response includes the album itself. Keep only its songs.
                    let tracks = lookupResponse.results.filter {
                        $0.wrapperType == "track" &&
                        $0.kind == "song" &&
                        $0.collectionId == collectionId
                    }

                    // Give the finished song list back to the detail screen.
                    completion(.success(tracks))
                } catch {
                    // Report a decoding error instead of showing incorrect data.
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
}
