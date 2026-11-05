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
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var discoverBackgroundImageView: UIImageView!

    private let musicService = MusicService()
    private var songs: [MusicItem] = []
    private var albums: [MusicItem] = []
    private var hasStartedBackgroundMotion = false

    private var musicItems: [MusicItem] {
        albums + songs
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        heroImageView.isUserInteractionEnabled = false
        tableView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !heroImageView.isHidden && !UIAccessibility.isReduceMotionEnabled {
            heroImageView.alpha = 0
            heroImageView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasStartedBackgroundMotion && !UIAccessibility.isReduceMotionEnabled {
            hasStartedBackgroundMotion = true

            UIView.animate(
                withDuration: 18,
                delay: 0,
                options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction]
            ) {
                self.discoverBackgroundImageView.transform =
                    CGAffineTransform(scaleX: 1.06, y: 1.06)
            }
        }

        guard !heroImageView.isHidden else { return }

        if UIAccessibility.isReduceMotionEnabled {
            heroImageView.alpha = 1
            return
        }

        UIView.animate(withDuration: 0.8, delay: 0.15, options: [.curveEaseOut]) {
            self.heroImageView.alpha = 1
            self.heroImageView.transform = .identity
        }
    }

    private func showEmptyDiscover() {
        songs = []
        albums = []
        tableView.reloadData()
        tableView.backgroundColor = .clear

        heroImageView.isHidden = false
        heroImageView.alpha = 1
        heroImageView.transform = .identity
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showEmptyDiscover()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !term.isEmpty else {
            showEmptyDiscover()
            return
        }

        searchBar.resignFirstResponder()

        heroImageView.isHidden = true
        tableView.backgroundColor = UIColor(named: "BsideBackground") ?? .white

        // Clear the previous search before loading this one.
        songs = []
        albums = []
        tableView.reloadData()

        musicService.search(for: term, type: .song) { [weak self, weak searchBar] result in
            guard let self = self,
                  searchBar?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == term else {
                return
            }

            switch result {
            case .success(let songs):
                self.songs = songs
                self.tableView.reloadData()
                print("Bside song search returned \(songs.count) results")

            case .failure(let error):
                print("Bside song search failed: \(error)")
            }
        }

        musicService.search(for: term, type: .album) { [weak self, weak searchBar] result in
            guard let self = self,
                  searchBar?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == term else {
                return
            }

            switch result {
            case .success(let albums):
                self.albums = albums
                self.tableView.reloadData()
                print("Bside album search returned \(albums.count) results")

            case .failure(let error):
                print("Bside album search failed: \(error)")
            }
        }
    }
}

// Gives the number of music results and the content for each Discover row.
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
