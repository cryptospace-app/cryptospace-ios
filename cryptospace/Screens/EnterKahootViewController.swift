// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class EnterKahootViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        // TODO: initial button title should be "paste"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
    }

    private func showWrongInputError() {
        
    }
    
    @IBAction func removeAccountButtonTapped(_ sender: Any) {
        Defaults.privateKey = nil
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else {
            textField.text = UIPasteboard.general.string
            return
        }
        
        let challengeKey = "challenge-id="
        guard let url = URL(string: text), let query = url.query, let challengeQueryItem = query.split(separator: "&").first(where: { $0.hasPrefix(challengeKey) }) else {
                showWrongInputError()
                return
        }
        let id = challengeQueryItem.dropFirst(challengeKey.count)
        guard !id.isEmpty else {
            showWrongInputError()
            return
        }
        
        let createSpace = instantiate(CreateSpaceViewController.self)
        createSpace.kahootId = String(id)
        navigationController?.pushViewController(createSpace, animated: true)
    }

}
