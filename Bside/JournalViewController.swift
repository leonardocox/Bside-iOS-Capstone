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

        title = "Journal"
        tableView.dataSource = self
        tableView.delegate = self
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
        )
        let review = reviews[indexPath.row]

        cell.textLabel?.text = review.musicItem.title
        cell.detailTextLabel?.text = review.musicItem.artistName
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}
