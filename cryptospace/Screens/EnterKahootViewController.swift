// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class EnterKahootViewController: UIViewController {

    private let ethereum = Ethereum.shared
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        // TODO: initial button title should be "paste"
        
        Ethereum.shared.getBalance { [weak self] result in
            guard case let .success(balance) = result else { return }
            self?.balanceLabel.text = balance
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
    }

    private func showWrongInputError() {
        // TODO: implement
    }
    
    private func didEnterKahootId(_ kahootId: String) {
//        ethereum.getContractChallenge(id: kahootId) { [weak self] result in
//            switch result {
//            case let .success(challenge):
//                if let challenge = challenge {
//                    let joinSpace = instantiate(JoinSpaceViewController.self)
//                    joinSpace.challenge = challenge
//                    self?.navigationController?.pushViewController(joinSpace, animated: true)
//                } else {
//                    let createSpace = instantiate(CreateSpaceViewController.self)
//                    createSpace.kahootId = kahootId
//                    self?.navigationController?.pushViewController(createSpace, animated: true)
//                }
//            case .failure:
//                // TODO: process error
//                break
//            }
//        }
    }
    
    @IBAction func removeAccountButtonTapped(_ sender: Any) {
        Defaults.privateKey = nil
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else {
            textField.text = UIPasteboard.general.string
            return
        }
        
        let challengeKey = "challenge-id="
        guard let url = URL(string: text), let query = url.query, let challengeQueryItem = query.split(separator: "&").first(where: { $0.hasPrefix(challengeKey) }) else {
                showWrongInputError()
                return
        }
        let id = challengeQueryItem.dropFirst(challengeKey.count)
        guard !id.isEmpty else {
            showWrongInputError()
            return
        }
        
        didEnterKahootId(String(id))
    }

}
