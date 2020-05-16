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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        guard let text = textField.text else { return }
        
        if let _ = try? EthPrivateKey(hex: text).address().value() {
            Defaults.privateKey = text
            let enterKahoot = instantiate(EnterKahootViewController.self)
            navigationController?.pushViewController(enterKahoot, animated: true)
        }
    }
    
}
