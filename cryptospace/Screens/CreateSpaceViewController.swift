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
        textField.becomeFirstResponder()
        // TODO: flash error message
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func didTapReturn() {
        guard var bidString = textField.text, Double(bidString) != nil, bidString != "0" else { return }
        textField.resignFirstResponder()
        createButton.setWaiting(true)
        
        if let dotIndex = bidString.firstIndex(where: { $0 == "." }) {
            while bidString.hasSuffix("0") {
                bidString.removeLast()
            }
            let fromTheStart = dotIndex.utf16Offset(in: bidString)
            let afterDot = bidString.count - fromTheStart - 1
            bidString.remove(at: dotIndex)
            bidString = bidString + Array(repeating: "0", count: 18 - afterDot).joined()
        } else {
            bidString = bidString + Array(repeating: "0", count: 18).joined()
        }
        
        while bidString.hasPrefix("0") {
            bidString.removeFirst()
        }
        
        let bid = EthNumber(decimal: bidString)
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
        Defaults.bid = bid
        let space = instantiate(SpaceViewController.self)
        space.kahootId = kahootId
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

