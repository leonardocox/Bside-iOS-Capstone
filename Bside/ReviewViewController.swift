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
    
    // the song or album passed from music detail
    var musicItem: MusicItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Review"

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

}
