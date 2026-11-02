//
//  SavedReviewViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 11/2/26.
//

import UIKit
import NukeExtensions

class SavedReviewViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var review: MusicReview?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Review"
        
        titleLabel.text = review?.musicItem.title
        artistLabel.text = review?.musicItem.artistName
        
        if let review = review {
            detailsLabel.text = """
            Rating: \(review.rating) / 5
            First Listen: \(review.firstListen ? "Yes" : "No")
            Liked: \(review.liked ? "Yes" : "No")
            """
            reviewTextView.text = review.reviewText
            
            dateLabel.text = "Saved \(review.createdAt.formatted(date: .abbreviated, time: .omitted))"
            
            NukeExtensions.loadImage(
                with: review.musicItem.artworkUrl100,
                into: artworkImageView
            )
        }
    }
}
