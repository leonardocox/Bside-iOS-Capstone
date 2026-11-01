//
//  ReviewViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/30/26.
//

import UIKit
import NukeExtensions

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var firstListenSwitch: UISwitch!
    @IBOutlet weak var likedSwitch: UISwitch!
    @IBOutlet weak var starStackView: UIStackView!
    
    // the song or album passed from music detail
    var musicItem: MusicItem?
    
    private var rating: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Review"
        
        configureStars()
        updateStars()

        if let musicItem = musicItem {
            titleLabel.text = musicItem.title
            artistLabel.text = musicItem.artistName
            print("Review received: \(musicItem.title) by \(musicItem.artistName)")

            NukeExtensions.loadImage(
                with: musicItem.artworkUrl100,
                into: artworkImageView
            )
        }
    }
    
    private func configureStars() {
        for view in starStackView.arrangedSubviews {
            guard let button = view as? UIButton else { continue }

            let tap = UITapGestureRecognizer(target: self, action: #selector(starTapped(_:)))
            button.addGestureRecognizer(tap)
            button.tintColor = .systemOrange
        }
    }

    @objc private func starTapped(_ recognizer: UITapGestureRecognizer) {
        guard let button = recognizer.view as? UIButton,
              let index = starStackView.arrangedSubviews.firstIndex(of: button) else {
            return
        }

        let tappedLeftHalf = recognizer.location(in: button).x < button.bounds.midX
        rating = Double(index) + (tappedLeftHalf ? 0.5 : 1.0)
        updateStars()
    }

    private func updateStars() {
        for (index, view) in starStackView.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }

            let imageName: String
            if rating >= Double(index + 1) {
                imageName = "star.fill"
            } else if rating >= Double(index) + 0.5 {
                imageName = "star.leadinghalf.filled"
            } else {
                imageName = "star"
            }

            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

}
