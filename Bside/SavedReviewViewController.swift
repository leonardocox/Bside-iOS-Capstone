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
        
        let backdrop = UIImageView(image: UIImage(named: "BsideDiscoverGlass"))
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.contentMode = .scaleAspectFill
        backdrop.clipsToBounds = true
        view.insertSubview(backdrop, at: 0)

        let softeningLayer = UIView()
        softeningLayer.translatesAutoresizingMaskIntoConstraints = false
        softeningLayer.backgroundColor = UIColor.white.withAlphaComponent(0.90)
        view.insertSubview(softeningLayer, aboveSubview: backdrop)

        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            softeningLayer.topAnchor.constraint(equalTo: view.topAnchor),
            softeningLayer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            softeningLayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            softeningLayer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        artworkImageView.layer.cornerRadius = 14
        artworkImageView.clipsToBounds = true
        artworkImageView.contentMode = .scaleAspectFill

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor(named: "BsideInk") ?? .label
        titleLabel.numberOfLines = 2

        artistLabel.font = .systemFont(ofSize: 17)
        artistLabel.textColor = .secondaryLabel

        detailsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        detailsLabel.textColor = UIColor(named: "BsideInk") ?? .label

        reviewTextView.font = .systemFont(ofSize: 17)
        reviewTextView.textColor = UIColor(named: "BsideInk") ?? .label
        reviewTextView.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        reviewTextView.layer.cornerRadius = 16
        reviewTextView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)

        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editReview)
        )
        
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
                with: review.musicItem.detailArtworkURL,
                into: artworkImageView
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let id = review?.id else { return }

        do {
            guard let updatedReview = try ReviewStore.load().first(where: { $0.id == id }) else {
                return
            }

            review = updatedReview
            titleLabel.text = updatedReview.musicItem.title
            artistLabel.text = updatedReview.musicItem.artistName

            detailsLabel.text = """
            Rating: \(updatedReview.rating) / 5
            First Listen: \(updatedReview.firstListen ? "Yes" : "No")
            Liked: \(updatedReview.liked ? "Yes" : "No")
            """

            reviewTextView.text = updatedReview.reviewText
            dateLabel.text = "Saved \(updatedReview.createdAt.formatted(date: .abbreviated, time: .omitted))"
        } catch {
            print("Could not refresh saved review: \(error)")
        }
    }
    
    @objc private func editReview() {
        performSegue(withIdentifier: "editSavedReview", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "editSavedReview",
              let destination = segue.destination as? ReviewViewController,
              let review = review else {
            return
        }

        destination.musicItem = review.musicItem
        destination.existingReview = review
    }
}
