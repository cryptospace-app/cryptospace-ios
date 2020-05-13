// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import web3

class EnterKeyViewController: UIViewController {
    
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        guard let _ = textField.text else { return }
        // TODO: create ethereum account
        let enterKahoot = instantiate(EnterKahootViewController.self)
        navigationController?.pushViewController(enterKahoot, animated: true)
    }
    
}
