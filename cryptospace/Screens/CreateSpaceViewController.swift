// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import Web3Swift

class CreateSpaceViewController: UIViewController {
    
    var kahootId: String!
    private let ethereum = Ethereum.shared
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        textField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        createButton.setWaiting(false)
    }
    
    private func didFailToCreate() {
        createButton.setWaiting(false)
        // TODO: flash error message
    }
    
    private func didTapReturn() {
        createButton.setWaiting(true)
        let bidStr = String(UInt64(0.001 * 1e18)) // TODO: get bid size from text field
        let bid = EthNumber(decimal: bidStr)
        let kahootId = self.kahootId!
        ethereum.createContractChallenge(id: kahootId, name: Defaults.name, bid: bid) { [weak self] success in
            if success {
                self?.didSendCreateTransaction(bid: bid)
            } else {
                self?.didFailToCreate()
            }
        }
    }
    
    private func didCreateChallenge(bid: EthNumber) {
        Defaults.kahootId = kahootId
        let space = instantiate(SpaceViewController.self)
        space.kahootId = kahootId
        space.bidSize = bid
        navigationController?.pushViewController(space, animated: true)
    }
    
    private func didSendCreateTransaction(bid: EthNumber) {
        ethereum.getBid(id: kahootId) { [weak self] result in
            if case let .success(resultBid) = result, resultBid != nil {
                self?.didCreateChallenge(bid: bid)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.didSendCreateTransaction(bid: bid)
                }
            }
        }
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        didTapReturn()
    }
    
}

extension CreateSpaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapReturn()
        return true
    }
    
}

