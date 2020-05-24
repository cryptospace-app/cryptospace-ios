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
            if let results = challenge.leaderboard?.players?.map({ "\($0.playerId) — \($0.finalScore)" }) {
                self?.results = results
                self?.tableView.reloadData()
            }
        }
    }
    
    // TODO: на viewWillAppear и каждые четыре секунды делать запросы: (не делать запросы, когда чувак ушел на GameViewController)
    // - isFinished
    // - players
    // - winner
    // - челендж с кахута
    
    // записывать все полученные данные в переменные
    
    // регулярно обновлять таблицу: показывать текущие результаты с кахута, добавлять к ним игроков с контракта, которые еще не появились в ответе кахута
    
    // в зависимости от состояния игры, при каждом обновлении данных, обновлять текст кнопки и действие при нажатии на нее (завести enum)
    
    // состояния кнопки:
    // - play (если еще не сыграл). она в самом начале, вызывает openGame()
    // - leave (если уже точно проебал) —
    // - get prize (если уже точно выиграл) — вызывает sendPrize, кнопка переходит в waiting state, пока не отправилась транзакция. если не отправилась, кнопка возвращается в обычное состояние, показывается сообщение об ошибке.
    // - спрятана (когда уже сыграл, но кто-то другой еще не доиграл)
    // - finish (если игра оказалась нечестной) — отправляется транзакция sendPrize. если не отправилась, просто вызывается leaveGame
    
    private func openGame() {
        let game = instantiate(GameViewController.self)
        present(game, animated: true)
    }
    
    private func leaveGame() {
        guard let enterKahoot = navigationController?.viewControllers.first(where: { $0 is EnterKahootViewController }) else { return }
        Defaults.kahootId = nil
        navigationController?.popToViewController(enterKahoot, animated: true)
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        openGame()
    }
    
    private func sendPrize() {
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
