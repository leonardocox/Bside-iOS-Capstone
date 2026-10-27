//
//  MusicDetailViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/26/26.
//

import UIKit
import NukeExtensions

class MusicDetailViewController: UIViewController {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var tracksTableView: UITableView!
    
    var musicItem: MusicItem?
    
    private let musicService = MusicService()
    private var tracks: [MusicItem] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Music Detail"

        guard let musicItem = musicItem else { return }

        titleLabel.text = musicItem.title
        artistLabel.text = musicItem.artistName
        NukeExtensions.loadImage(with: musicItem.artworkUrl100, into: artworkImageView)
        
        // A directly selected song has no album track list to show.
        tracksTableView.isHidden = !musicItem.isAlbum

        // Only albums with a collection ID can request their songs.
        if musicItem.isAlbum, let collectionId = musicItem.collectionId {
            musicService.tracks(for: collectionId) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let tracks):
                    self.tracks = tracks
                    self.tracksTableView.reloadData()

                case .failure(let error):
                    print("Bside album tracks failed: \(error)")
                }
            }
        }
    }
}

// Supplies one table row for each song returned in the album lookup.
extension MusicDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TrackCell",
            for: indexPath
        )

        cell.textLabel?.text = tracks[indexPath.row].title
        return cell
    }
}

// Opens the selected album track using the existing Music Detail storyboard scene.
extension MusicDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let songDetail = storyboard?.instantiateViewController(
            withIdentifier: "MusicDetailScene"
        ) as? MusicDetailViewController else {
            return
        }

        songDetail.musicItem = tracks[indexPath.row]
        navigationController?.pushViewController(songDetail, animated: true)
    }
}
