//
//  JournalReviewCell.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 11/5/26.
//

import UIKit
import NukeExtensions

class JournalReviewCell: UITableViewCell {
    private let cardView = UIView()
    private let artworkView = UIImageView()
    private let musicTitleLabel = UILabel()
    private let metadataLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private var didSetUpLayout = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpLayout()
    }

    private func setUpLayout() {
        guard !didSetUpLayout else { return }
        didSetUpLayout = true

        // The storyboard's original labels are replaced by the card's labels.
        contentView.subviews
            .compactMap { $0 as? UILabel }
            .forEach { $0.isHidden = true }

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.82)
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
        cardView.clipsToBounds = true

        artworkView.translatesAutoresizingMaskIntoConstraints = false
        artworkView.contentMode = .scaleAspectFill
        artworkView.clipsToBounds = true
        artworkView.layer.cornerRadius = 10
        artworkView.backgroundColor = .systemGray6

        musicTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        musicTitleLabel.textColor = UIColor(named: "BsideInk") ?? .label
        musicTitleLabel.numberOfLines = 2

        metadataLabel.font = .systemFont(ofSize: 13)
        metadataLabel.textColor = .secondaryLabel
        metadataLabel.numberOfLines = 1

        let labels = UIStackView(arrangedSubviews: [
            musicTitleLabel,
            metadataLabel
        ])
        labels.axis = .vertical
        labels.spacing = 5
        labels.translatesAutoresizingMaskIntoConstraints = false

        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.tintColor = UIColor(named: "BsideInk")?.withAlphaComponent(0.5)
            ?? .systemGray3
        chevronView.contentMode = .scaleAspectFit

        contentView.addSubview(cardView)
        cardView.addSubview(artworkView)
        cardView.addSubview(labels)
        cardView.addSubview(chevronView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            artworkView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            artworkView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            artworkView.widthAnchor.constraint(equalToConstant: 68),
            artworkView.heightAnchor.constraint(equalToConstant: 68),

            labels.leadingAnchor.constraint(equalTo: artworkView.trailingAnchor, constant: 14),
            labels.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -10),
            labels.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 10),
            chevronView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(with review: MusicReview) {
        musicTitleLabel.text = review.musicItem.title
        metadataLabel.text = "\(review.musicItem.artistName)  ·  \(review.rating.formatted()) ★"

        artworkView.image = nil
        NukeExtensions.loadImage(
            with: review.musicItem.artworkUrl100,
            into: artworkView
        )

        accessoryType = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.image = nil
    }
}
