//
//  ViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/22/26.
//

import UIKit
import NukeExtensions

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private let musicService = MusicService()
    private var songs: [MusicItem] = []
    private var albums: [MusicItem] = []
    
    private var musicItems: [MusicItem] {
        albums + songs
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showMusicDetail",
              let selectedCell = sender as? MusicResultCell,
              let indexPath = tableView.indexPath(for: selectedCell),
              let detailViewController = segue.destination as? MusicDetailViewController else {
            return
        }

        detailViewController.musicItem = musicItems[indexPath.row]
    }


}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !term.isEmpty else {
            return
        }

        searchBar.resignFirstResponder()
        
        // makes a new search start with an empty list
        songs = []
        albums = []
        tableView.reloadData()

        // Check that real song results can be fetched and decoded.
        musicService.search(for: term, type: .song) { result in
            switch result {
            case .success(let songs):
                self.songs = songs
                self.tableView.reloadData()
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
                self.albums = albums
                self.tableView.reloadData()
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

// gives the number of music results and the content for each discover row
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        musicItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MusicCell",
            for: indexPath
        ) as! MusicResultCell

        let item = musicItems[indexPath.row]

        cell.titleLabel.text = item.title
        cell.artistLabel.text = item.artistName
        cell.artworkImageView.image = nil
        NukeExtensions.loadImage(with: item.artworkUrl100, into: cell.artworkImageView)

        return cell
    }
}
