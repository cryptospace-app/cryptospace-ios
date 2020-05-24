// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class EnterNameViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        didTapReturn()
    }
    
    private func didTapReturn() {
        if let name = textField.text, !name.isEmpty {
            Defaults.name = name
            let enterKahoot = instantiate(EnterKahootViewController.self)
            navigationController?.pushViewController(enterKahoot, animated: true)
        } else {
            // TODO: flash error message
        }
    }
    
}

extension EnterNameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapReturn()
        return true
    }
    
}
