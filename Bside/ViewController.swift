//
//  ViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/22/26.
//

import UIKit

class ViewController: UIViewController {
    
    private let musicService = MusicService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !term.isEmpty else {
            return
        }

        searchBar.resignFirstResponder()

        // Check that real song results can be fetched and decoded.
        musicService.search(for: term, type: .song) { result in
            switch result {
            case .success(let songs):
                print("Bside song search returned \(songs.count) results")

                if let firstSong = songs.first {
                    print("First song: \(firstSong.title) by \(firstSong.artistName)")
                }

            case .failure(let error):
                print("Bside song search failed: \(error)")
            }
        }

        // Check that the same model also decodes album results.
        musicService.search(for: term, type: .album) { result in
            switch result {
            case .success(let albums):
                print("Bside album search returned \(albums.count) results")

                if let firstAlbum = albums.first {
                    print("First album: \(firstAlbum.title) by \(firstAlbum.artistName)")
                }

            case .failure(let error):
                print("Bside album search failed: \(error)")
            }
        }
    }
}
