// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import Web3Swift

class SpaceViewController: UIViewController {

    var kahootId: String!
    var bidSize: EthNumber?
    var playersFromContract = [String]()
    
    private let ethereum = Ethereum.shared
    private var results = [String]()
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        NetworkService.shared.getChallenge(id: kahootId) { [weak self] result in
            guard case .success(let challenge) = result else { return }
            let results = challenge.leaderboard.players.map { "\($0.playerId) — \($0.finalScore)" }
            self?.results = results
            self?.tableView.reloadData()
        }
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        ethereum.sendPrize(id: kahootId) { [weak self] success in
            if success {
                guard let enterKahoot = self?.navigationController?.viewControllers.first(where: { $0 is EnterKahootViewController }) else { return }
                self?.navigationController?.popToViewController(enterKahoot, animated: true)
                Defaults.kahootId = nil
                // TODO: show some congratulation
            } else {
                // TODO: process error
            }
        }
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
