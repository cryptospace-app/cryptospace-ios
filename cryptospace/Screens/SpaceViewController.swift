// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import Web3Swift

struct PlayerCellModel: Equatable {
    let name: String
    let score: Int
    var itsMe: Bool
    var isWinner: Bool
}

class SpaceViewController: UIViewController {

    private var gameState = GameState.unknown
    
    enum GameState {
        case unknown, toBePlayed, youLost, youWon, someoneElseIsPlaying, gameWasUnfair
    }
    
    var kahootId: String!
    
    private var playerCellModels = [PlayerCellModel]()
    
    var playersFromContract = [String]()
    
    private var challenge: Challenge?
    private var isFinished = false
    private var winnerName = ""
    
    private let bid = Defaults.bid!
    private let ethereum = Ethereum.shared
    private var refreshTimer: Timer?
    
    @IBOutlet weak var titleLabel: UILabel!
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
        updateTitle()
        refreshData()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.refreshData()
        }
    }
    
    private func updateTitle() {
        let text: String
        switch gameState {
        case .gameWasUnfair:
            text = "Game was unfair"
        case .someoneElseIsPlaying:
            text = "Waiting for other players to finish"
        case .toBePlayed, .youWon:
            text = "🏆 = \(bid.prizeFor(playersFromContract.count))"
        case .unknown:
            text = "Welcome"
        case .youLost:
            text = "You've lost"
        }
        titleLabel.text = text
    }
    
    private func didFailToSendPrize() {
        showErrorMessage("Please try again")
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
        var newCellModels = [PlayerCellModel]()
        var newGameState = GameState.unknown
        
        let kahootPlayers = challenge?.leaderboard?.players ?? []
        
        var playersWithScores: [(player: String, score: Int)] = kahootPlayers.map({ (player: $0.playerId, score: $0.finalScore) })
        for playerOnContract in playersFromContract {
            if !playersWithScores.contains(where: { $0.player.lowercased() == playerOnContract }) {
                playersWithScores.append((player: playerOnContract, score: 0))
            }
        }
        
        newCellModels = playersWithScores.map { PlayerCellModel(name: $0.player.lowercased(), score: $0.score, itsMe: false, isWinner: false) }
        
        let total = challenge?.summary?.totalAnswerCount
        
        let gameIsFinished = kahootPlayers.count == playersFromContract.count && !kahootPlayers.contains(where: { $0.isGameUnfinished(total: total) })
        let leaderName = kahootPlayers.first(where: { $0.rank == 1 })?.playerId
        let leaderIsMe = leaderName?.lowercased() == Defaults.name.lowercased()
        let myGameIsFinished = !(kahootPlayers.first(where: { $0.playerId == Defaults.name })?.isGameUnfinished(total: total) ?? true)
        
        for i in 0..<newCellModels.count {
            let model = newCellModels[i]
            if model.name == leaderName {
                newCellModels[i].isWinner = true
            }
            if model.name == Defaults.name {
                newCellModels[i].itsMe = true
            }
        }
        
        if gameIsFinished {
            if playersFromContract.isEmpty {
                newGameState = .unknown
            } else {
                newGameState = leaderIsMe ? .youWon : .youLost
            }
        } else {
            newGameState = myGameIsFinished ? .someoneElseIsPlaying : .toBePlayed
        }
        
        let onContract = Set(playersFromContract)
        if kahootPlayers.contains(where: { !onContract.contains($0.playerId.lowercased()) }) {
            newGameState = .gameWasUnfair
        }
        
        gameState = newGameState
        
        if newCellModels != playerCellModels {
            playerCellModels = newCellModels
            tableView.reloadData()
        }
        
        if !activityIndicator.isHidden, !playerCellModels.isEmpty {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        updateButton()
        updateTitle()
    }
    
    private func updateButton() {
        let title: String?
        switch gameState {
        case .toBePlayed:
            title = "Play"
        case .youLost:
            title = "Leave game"
        case .gameWasUnfair:
            title = "Get money back"
        case .youWon:
            title = "Get prize 🎉"
        case .someoneElseIsPlaying, .unknown:
            title = nil
        }
        
        if let title = title {
            actionButton.isHidden = false
            if actionButton.title(for: .normal) != title {
                actionButton.setTitle(title, for: .normal)
            }
        } else {
            actionButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    private func openGame() {
        let game = instantiate(GameViewController.self)
        present(game, animated: true)
    }
    
    private func leaveGame() {
        guard let enterKahoot = navigationController?.viewControllers.first(where: { $0 is EnterKahootViewController }) else { return }
        Defaults.kahootId = nil
        Defaults.bid = nil
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerCellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellOfType(PlayerCell.self, for: indexPath)
        let model = playerCellModels[indexPath.row]
        cell.setup(model)
        return cell
    }
    
}
