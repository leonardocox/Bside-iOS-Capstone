//
//  ReviewViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 10/30/26.
//

import UIKit
import NukeExtensions

class ReviewViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var firstListenSwitch: UISwitch!
    @IBOutlet weak var likedSwitch: UISwitch!
    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet weak var reviewTextView: UITextView!
    
    // the song or album passed from music detail
    var musicItem: MusicItem?
    
    private var rating: Double = 0
    private let reviewPlaceholder = "Write a review?"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Review"
        
        configureStars()
        updateStars()
        
        reviewTextView.delegate = self
        reviewTextView.text = reviewPlaceholder
        reviewTextView.textColor = .placeholderText
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            ),
            UIBarButtonItem(
                title: "Done",
                style: .plain,
                target: self,
                action: #selector(doneWriting)
            )
        ]
        reviewTextView.inputAccessoryView = toolbar
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        // Measure from the storyboard position, even if the view was already moved.
        view.transform = .identity
        let textFrame = reviewTextView.convert(reviewTextView.bounds, to: nil)
        let overlap = textFrame.maxY + 16 - keyboardFrame.minY

        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform(
                translationX: 0,
                y: -max(0, overlap)
            )
        }
    }
    
    @objc private func doneWriting() {
        reviewTextView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == reviewPlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = reviewPlaceholder
            textView.textColor = .placeholderText
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = .identity
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    

}
