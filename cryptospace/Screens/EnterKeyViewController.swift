// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import web3
import Web3Swift

class EnterKeyViewController: KeyboardDependentViewController {
    
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        endEditingOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
    }
    
    // TODO: update button title when valid key is entered
    
    // TODO: rise button with keyboard - Ivan has code for that
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        if isValidPrivateKey(textField.text ?? "") {
            enterButton.setTitle("Next", for: .normal)
        } else {
            enterButton.setTitle("Paste", for: .normal)
        }
    }
    
    private func isValidPrivateKey(_ key: String) -> Bool {
        if let _ = try? EthPrivateKey(hex: key).address().value() {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func textFieldEditingDidEnd(_ sender: Any) {
        
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        // TODO: button should paste unless valid private key is entered
        guard let text = textField.text, !text.isEmpty else {
            textField.text = UIPasteboard.general.string
            return
        }
        
        if let address = try? EthPrivateKey(hex: text).address().value().toHexString() {
            Defaults.privateKey = text
            enterButton.setWaiting(true)
            
            Ethereum.shared.getENSName(address:"0x" + address) { [weak self] result in
                DispatchQueue.main.async {
                    self?.enterButton.setWaiting(false)
                    if let ensName = result {
                        Defaults.name = ensName
                        let enterKahoot = instantiate(EnterKahootViewController.self)
                        self?.navigationController?.pushViewController(enterKahoot, animated: true)
                    } else {
                        let enterName = instantiate(EnterNameViewController.self)
                        self?.navigationController?.pushViewController(enterName, animated: true)
                    }
                }
            }
        }
    }
    
}
