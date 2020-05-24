// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class EnterNameViewController: KeyboardDependentViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: make text field first responser
        // TODO: rise button with keyboard
        endEditingOnTap()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let name = textField.text, !name.isEmpty {
            Defaults.name = name
            let enterKahoot = instantiate(EnterKahootViewController.self)
            navigationController?.pushViewController(enterKahoot, animated: true)
        } else {
            // TODO: flash error message
        }
    }
    
}
