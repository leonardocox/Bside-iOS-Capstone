//
//  JournalViewController.swift
//  Bside
//
//  Created by Leonardo Giovanni Cox on 11/2/26.
//

import UIKit

class JournalViewController: UIViewController,
                             UITableViewDataSource,
                             UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var reviews: [MusicReview] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let heading = UILabel()
        heading.text = "journal"
        heading.font = .systemFont(ofSize: 25, weight: .bold)
        heading.textColor = UIColor(named: "BsideInk") ?? .label
        navigationItem.titleView = heading
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 116
        tableView.separatorStyle = .none
        
        let backdrop = UIView(frame: tableView.bounds)

        let artwork = UIImageView(image: UIImage(named: "BsideDiscoverGlass"))
        artwork.contentMode = .scaleAspectFill
        artwork.clipsToBounds = true
        artwork.translatesAutoresizingMaskIntoConstraints = false
        backdrop.addSubview(artwork)

        let softeningLayer = UIView()
        softeningLayer.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        softeningLayer.translatesAutoresizingMaskIntoConstraints = false
        backdrop.addSubview(softeningLayer)

        NSLayoutConstraint.activate([
            artwork.topAnchor.constraint(equalTo: backdrop.topAnchor),
            artwork.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor),
            artwork.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor),
            artwork.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor),

            softeningLayer.topAnchor.constraint(equalTo: backdrop.topAnchor),
            softeningLayer.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor),
            softeningLayer.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor),
            softeningLayer.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor)
        ])

        tableView.backgroundView = backdrop
        tableView.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        do {
            reviews = try ReviewStore.load()
            tableView.reloadData()
        } catch {
            print("Could not load reviews: \(error)")
            let alert = UIAlertController(
                title: "Could Not Load Journal",
                message: "Your saved reviews could not be read.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showSavedReview",
              let destination = segue.destination as? SavedReviewViewController,
              let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        destination.review = reviews[indexPath.row]
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewCell",
            for: indexPath
        ) as! JournalReviewCell

        cell.configure(with: reviews[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {

        let review = reviews[indexPath.row]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            let alert = UIAlertController(
                title: "Delete Review?",
                message: "This will remove your review of \(review.musicItem.title).",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            })

            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                do {
                    try ReviewStore.delete(id: review.id)
                    self.reviews = try ReviewStore.load()
                    self.tableView.reloadData()
                    completion(true)
                } catch {
                    print("Review delete failed: \(error)")
                    completion(false)

                    let errorAlert = UIAlertController(
                        title: "Could Not Delete Review",
                        message: "Please try again.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            })

            self.present(alert, animated: true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
