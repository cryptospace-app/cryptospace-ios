// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import Web3Swift

class JoinSpaceViewController: UIViewController {

    var challengeId: String!
    var bid: EthNumber!
    var players: [String]!
    
    private let ethereum = Ethereum.shared
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var challengeNameLabel: UILabel!
    @IBOutlet weak var prizeSizeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func joinButtonTapped(_ sender: Any) {
        // TODO: implement join
//        ethereum.joinContractChallenge(id: challenge.id, name: Defaults.name, bidSize: 0.01) { [weak self] success in
//            if success {
//                Defaults.kahootId = challenge.id // TODO: it'd better to store entire challenge model
//                let space = instantiate(SpaceViewController.self)
//                space.kahootId = challenge.id
//                self?.navigationController?.pushViewController(space, animated: true)
//            } else {
//                // TODO: process error
//            }
//        }
    }
    
}
