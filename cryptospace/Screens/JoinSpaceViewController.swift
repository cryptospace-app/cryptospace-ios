// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class JoinSpaceViewController: UIViewController {

    var challenge: ContractChallenge!
    private let ethereum = Ethereum.shared
    
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func joinButtonTapped(_ sender: Any) {
        let challenge = self.challenge!
        ethereum.joinContractChallenge(challenge, name: Defaults.name) { [weak self] success in
            if success {
                Defaults.kahootId = challenge.id // TODO: it'd better to store entire challenge model
                let space = instantiate(SpaceViewController.self)
                space.kahootId = challenge.id
                self?.navigationController?.pushViewController(space, animated: true)
            } else {
                // TODO: process error
            }
        }
    }
    
}
