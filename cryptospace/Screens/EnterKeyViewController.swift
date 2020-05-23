// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import web3
import Web3Swift

class EnterKeyViewController: UIViewController {
    
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
    
    private let ens = EthereumNameService(
        client: EthereumClient(url:
            URL(string: "https://ropsten.infura.io/v3/3f99b6096fda424bbb26e17866dcddfc")!
        ),
        registryAddress: EthereumAddress("0x112234455c3a32fd11230c42e7bccd4a84e02010")
    )
    
    private func getENSName(address: String, completion: @escaping (String?) -> Void) {
        ens.resolve(address: EthereumAddress(address)) { error, result  in
            if error != nil || result == nil {
                completion(nil)
            } else {
                completion(result)
            }
        }
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        // TODO: button should paste unless valid private key is entered
        guard let text = textField.text, !text.isEmpty else {
            textField.text = UIPasteboard.general.string
            return
        }
        
        if let address = try? EthPrivateKey(hex: text).address().value().toHexString() {
            Defaults.privateKey = text
            
            
            getENSName(address:"0x" + address) { result in
                
            }
            // TODO: retreive ens name after address is known. if there is no ens name, then push name screen
            if false {
                let enterKahoot = instantiate(EnterKahootViewController.self)
                navigationController?.pushViewController(enterKahoot, animated: true)
            } else {
                let enterName = instantiate(EnterNameViewController.self)
                navigationController?.pushViewController(enterName, animated: true)
            }
        }
    }
    
}
