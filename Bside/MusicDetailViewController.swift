//
//  MusicDetailViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/26/26.
//

import UIKit
import NukeExtensions
import AVFoundation

class MusicDetailViewController: UIViewController {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var previewButtonHeightConstraint: NSLayoutConstraint!
    
    @IBAction func previewTapped(_ sender: Any) {
        guard let musicItem = musicItem,
              !musicItem.isAlbum,
              let previewURL = musicItem.previewUrl else {
            return
        }
        print("BSIDE PREVIEW URL: \(previewURL)")

        if let previewPlayer = previewPlayer {
            if previewPlayer.rate > 0 {
                previewPlayer.pause()
                previewButton.setTitle("Play Preview", for: .normal)
            } else {
                previewPlayer.play()
                previewButton.setTitle("Pause Preview", for: .normal)
            }
        } else {
            previewPlayer = AVPlayer(url: previewURL)
            previewPlayer?.play()
            previewButton.setTitle("Pause Preview", for: .normal)
        }
    }
    
    @objc private func trackPreviewTapped(_ sender: UIButton) {
        let index = sender.tag
        guard tracks.indices.contains(index),
              let url = tracks[index].previewUrl else { return }

        if playingTrackIndex == index {
            previewPlayer?.pause()
            previewPlayer = nil
            playingTrackIndex = nil
        } else {
            previewPlayer?.pause()
            previewPlayer = AVPlayer(url: url)
            previewPlayer?.play()
            playingTrackIndex = index
        }

        tracksTableView.reloadData()
    }
    
    @objc private func previewDidFinish(_ notification: Notification) {
        guard let finishedItem = notification.object as? AVPlayerItem else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.previewPlayer?.currentItem === finishedItem else { return }

            self.previewPlayer = nil
            self.playingTrackIndex = nil

            if self.musicItem?.isAlbum == true {
                self.tracksTableView.reloadData()
            } else {
                self.previewButton.setTitle("Play Preview", for: .normal)
            }
        }
    }
        
    var musicItem: MusicItem?
    
    private let musicService = MusicService()
    private var tracks: [MusicItem] = []
    private var previewPlayer: AVPlayer?
    private var playingTrackIndex: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(previewDidFinish(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )

        title = "Music Detail"

        guard let musicItem = musicItem else { return }

        titleLabel.text = musicItem.title
        artistLabel.text = musicItem.artistName
        NukeExtensions.loadImage(with: musicItem.artworkUrl100, into: artworkImageView)
        
        // A directly selected song has no album track list to show.
        tracksTableView.isHidden = !musicItem.isAlbum
        previewButton.isHidden = musicItem.isAlbum || musicItem.previewUrl == nil
        previewButtonHeightConstraint.constant = previewButton.isHidden ? 0 : 44

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewPlayer?.pause()
        previewPlayer = nil
        playingTrackIndex = nil
        previewButton.setTitle("Play Preview", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showReview",
              let reviewViewController = segue.destination as? ReviewViewController else {
            return
        }

        reviewViewController.musicItem = musicItem
    }
    
    // this is for setting the play button back in case the preview ends naturally
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TrackCell",
            for: indexPath
        ) as? TrackPreviewCell else {
            return UITableViewCell()
        }

        cell.trackTitleLabel.text = tracks[indexPath.row].title
        
        cell.trackPreviewButton.tag = indexPath.row
        cell.trackPreviewButton.isEnabled = tracks[indexPath.row].previewUrl != nil
        cell.trackPreviewButton.setTitle(
            playingTrackIndex == indexPath.row ? "❚❚" : "▶",
            for: .normal
        )
        cell.trackPreviewButton.removeTarget(
            self,
            action: #selector(trackPreviewTapped(_:)),
            for: .touchUpInside
        )
        cell.trackPreviewButton.addTarget(
            self,
            action: #selector(trackPreviewTapped(_:)),
            for: .touchUpInside
        )
        
        var background = UIBackgroundConfiguration.listCell()
        background.backgroundColor = UIColor(named: "BsideBackground")
        cell.backgroundConfiguration = background
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
