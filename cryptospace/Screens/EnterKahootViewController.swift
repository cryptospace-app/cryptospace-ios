// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class EnterKahootViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        guard let text = textField.text else { return }
        let createSpace = instantiate(CreateSpaceViewController.self)
        createSpace.kahootId = text
        navigationController?.pushViewController(createSpace, animated: true)
    }

}
