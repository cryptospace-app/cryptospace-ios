// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import Web3Swift

class EnterKahootViewController: UIViewController {
    
    private let ethereum = Ethereum.shared
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        nameLabel.text = "👤 " + Defaults.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
        updateBalance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        enterButton.setWaiting(false)
    }
    
    private func updateBalance() {
        Ethereum.shared.getBalance { [weak self] result in
            guard case let .success(balance) = result else { return }
            self?.balanceLabel.text = balance
        }
    }
    
    private func showWrongInputError() {
        // TODO: implement
    }
    
    private func updateButtonTitle() {
        let hasInput = textField.text?.isEmpty == false
        let newTitle = hasInput ? "Continue" : "Paste"
        if newTitle != enterButton.title(for: .normal) {
            enterButton.setTitle(newTitle, for: .normal)
        }
    }
    
    private func didEnterKahootId(_ kahootId: String) {
        enterButton.setWaiting(true)
        ethereum.getBid(id: kahootId) { [weak self] result in
            switch result {
            case let .success(bid):
                if let bid = bid {
                    self?.join(kahootId: kahootId, bid: bid)
                } else {
                    let createSpace = instantiate(CreateSpaceViewController.self)
                    createSpace.kahootId = kahootId
                    self?.navigationController?.pushViewController(createSpace, animated: true)
                }
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.didEnterKahootId(kahootId)
                }
            }
        }
    }
    
    private func join(kahootId: String, bid: EthNumber) {
        ethereum.getPlayers(id: kahootId) { [weak self] result in
            switch result {
            case let .success(players):
                let joinSpace = instantiate(JoinSpaceViewController.self)
                joinSpace.players = players
                joinSpace.bid = bid
                joinSpace.challengeId = kahootId
                self?.navigationController?.pushViewController(joinSpace, animated: true)
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.join(kahootId: kahootId, bid: bid)
                }
            }
        }
    }
    
    @IBAction func removeAccountButtonTapped(_ sender: Any) {
        Defaults.privateKey = nil
        Defaults.name = ""
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else {
            textField.text = UIPasteboard.general.string
            updateButtonTitle()
            return
        }
        
        let challengeKey = "challenge-id="
        guard let url = URL(string: text), let query = url.query, let challengeQueryItem = query.split(separator: "&").first(where: { $0.hasPrefix(challengeKey) }) else {
            tryToDecode(text)
            return
        }
        Defaults.kahootURL = text
        let id = challengeQueryItem.dropFirst(challengeKey.count)
        guard !id.isEmpty else {
            tryToDecode(text)
            return
        }
        
        didEnterKahootId(String(id))
    }
    
    private func tryToDecode(_ text: String) {
        let neededPrefix = "https://kahoot.it/challenge/"
        guard text.hasPrefix(neededPrefix) else {
            showWrongInputError()
            return
        }
        let id = String(text.dropFirst(neededPrefix.count))
        let seperators = CharacterSet(charactersIn: "/&?")
        if id.rangeOfCharacter(from: seperators) == nil {
            didEnterKahootId(id)
        } else {
            showWrongInputError()
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        updateButtonTitle()
    }
    
}
