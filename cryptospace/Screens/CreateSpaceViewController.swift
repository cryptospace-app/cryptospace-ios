// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class CreateSpaceViewController: KeyboardDependentViewController {

    var kahootId: String!
    private let ethereum = Ethereum.shared
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func createButtonTapped(_ sender: Any) {
        let kahootId = self.kahootId!
        // TODO: name and bid size should be correct
        ethereum.createContractChallenge(id: kahootId, name: Defaults.name, bidSize: 0.001) { [weak self] success in
            if success {
                Defaults.kahootId = kahootId
                let space = instantiate(SpaceViewController.self)
                space.kahootId = kahootId
                self?.navigationController?.pushViewController(space, animated: true)
            } else {
                // TODO: process error
            }
        }
    }
    
}
