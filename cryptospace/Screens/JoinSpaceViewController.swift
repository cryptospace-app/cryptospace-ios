// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import Web3Swift

class JoinSpaceViewController: UIViewController {

    var challengeId: String!
    var bid: EthNumber!
    var players: [String]!
    
    private let ethereum = Ethereum.shared
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var challengeNameLabel: UILabel!
    @IBOutlet weak var prizeSizeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        let prizeString = bid.prizeFor(players.count)
        let bidString = bid.ethString
        prizeSizeLabel.text = "Prize is \(prizeString)"
        joinButton.setTitle("Join for \(bidString)", for: .normal)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        joinButton.setWaiting(false)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func didFailToJoin() {
        joinButton.setWaiting(false)
        // TODO: flash error message
    }
    
    private func didJoinChallenge(withPlayers players: [String]) {
        Defaults.kahootId = challengeId
        let space = instantiate(SpaceViewController.self)
        space.kahootId = challengeId
        Defaults.bid = bid
        space.playersFromContract = players
        navigationController?.pushViewController(space, animated: true)
    }
    
    private func didSendJoinTransaction() {
        ethereum.getPlayers(id: challengeId) { [weak self] result in
            if case let .success(players) = result, players.contains(where: { $0.lowercased() == Defaults.name.lowercased() }) {
                self?.didJoinChallenge(withPlayers: players)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.didSendJoinTransaction()
                }
            }
        }
    }
    
    @IBAction func joinButtonTapped(_ sender: Any) {
        joinButton.setWaiting(true)
        ethereum.joinContractChallenge(id: challengeId, name: Defaults.name, bid: bid) { [weak self] success in
            if success {
                self?.didSendJoinTransaction()
            } else {
                self?.didFailToJoin()
            }
        }
    }
    
}
