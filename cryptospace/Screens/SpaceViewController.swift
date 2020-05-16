// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class SpaceViewController: UIViewController {

    var kahootId: String!
    
    private var results = [String]()
    
    @IBOutlet weak var getPrizeButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        Network.shared.getChallenge(id: kahootId) { [weak self] result in
            guard case .success(let challenge) = result else { return }
            let results = challenge.leaderboard.players.map { "\($0.playerId) — \($0.finalScore)" }
            self?.results = results
            self?.tableView.reloadData()
        }
    }

    @IBAction func getPrizeButtonTapped(_ sender: Any) {
        guard let enterKahoot = navigationController?.viewControllers.first(where: { $0 is EnterKahootViewController }) else { return }
        navigationController?.popToViewController(enterKahoot, animated: true)
        Defaults.kahootId = nil
    }
    
}

extension SpaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension SpaceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
    
}
