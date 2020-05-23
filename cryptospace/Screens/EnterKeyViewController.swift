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
        
    }
    
    
    @IBAction func textFieldEditingDidEnd(_ sender: Any) {
        
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        // TODO: button should paste unless valid private key is entered
        guard let text = textField.text, !text.isEmpty else {
            textField.text = UIPasteboard.general.string
            return
        }
        
        if let _ = try? EthPrivateKey(hex: text).address().value() {
            Defaults.privateKey = text
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
