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
    
    var musicItem: MusicItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Music Detail"

        guard let musicItem = musicItem else { return }

        titleLabel.text = musicItem.title
        artistLabel.text = musicItem.artistName
        NukeExtensions.loadImage(with: musicItem.artworkUrl100, into: artworkImageView)
    }
}
