// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import Web3Swift

class SpaceViewController: UIViewController {

    private var gameState = GameState.unknown

    struct PlayerCellModel {
        let name: String
        let score: String
    }
    
    enum GameState {
        case unknown, toBePlayed, youLost, youWon, someoneElseIsPlaying, gameWasUnfair
    }
    
    var kahootId: String!
    
    private var playerCellModels = [PlayerCellModel]()
    
    var bidSize: EthNumber?
    var playersFromContract = [String]()
    private var challenge: Challenge?
    private var isFinished = false
    private var winnerName = ""
    
    private let ethereum = Ethereum.shared
    private var refreshTimer: Timer?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
        
        refreshData()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.refreshData()
        }
    }
    
    private func didFailToSendPrize() {
        // TODO: show error message
    }
    
    deinit {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @objc private func refreshData() {
        ethereum.getIsFinished(id: kahootId) { [weak self] result in
            if case let .success(finished) = result {
                self?.isFinished = finished
                self?.update()
            }
        }
        
        ethereum.getPlayers(id: kahootId) { [weak self] result in
            if case let .success(names) = result {
                self?.playersFromContract = names
                self?.update()
            }
        }
        
        ethereum.getWinner(id: kahootId) { [weak self] result in
            if case let .success(winner) = result {
                self?.winnerName = winner
                self?.update()
            }
        }
        
        NetworkService.shared.getChallenge(id: kahootId) { [weak self] result in
            guard case .success(let challenge) = result else { return }
            self?.challenge = challenge
            self?.update()
        }
    }
    
    private func update() {
        // TODO: update table view
        // TODO: update game state
        // TODO: update button
        // TODO: stop animating activityIndicator
    }
    
    // MARK: - Actions
    
    private func openGame() {
        let game = instantiate(GameViewController.self)
        present(game, animated: true)
    }
    
    private func leaveGame() {
        guard let enterKahoot = navigationController?.viewControllers.first(where: { $0 is EnterKahootViewController }) else { return }
        Defaults.kahootId = nil
        navigationController?.popToViewController(enterKahoot, animated: true)
    }
    
    private func sendPrize(leaveIfFailed: Bool) {
        actionButton.setWaiting(true)
        ethereum.sendPrize(id: kahootId) { [weak self] success in
            if success || leaveIfFailed {
                self?.leaveGame()
            } else {
                self?.actionButton.setWaiting(false)
                self?.didFailToSendPrize()
            }
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        switch gameState {
        case .toBePlayed:
            openGame()
        case .youLost:
            leaveGame()
        case .gameWasUnfair:
            sendPrize(leaveIfFailed: true)
        case .youWon:
            sendPrize(leaveIfFailed: false)
        case .someoneElseIsPlaying, .unknown:
            break
        }
    }
    
}

extension SpaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension SpaceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerCellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = playerCellModels[indexPath.row].name + " " + String(playerCellModels[indexPath.row].score)
        return cell
    }
    
}
