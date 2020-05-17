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
        // TODO: initial button title should be "paste"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else {
            textField.text = UIPasteboard.general.string
            return
        }
        
        if let _ = try? EthPrivateKey(hex: text).address().value() {
            Defaults.privateKey = text
            let enterKahoot = instantiate(EnterKahootViewController.self)
            navigationController?.pushViewController(enterKahoot, animated: true)
        }
    }
    
}
