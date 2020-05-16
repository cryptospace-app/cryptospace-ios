// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class JoinSpaceViewController: UIViewController {

    var kahootId: String!
    
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func joinButtonTapped(_ sender: Any) {
        Defaults.kahootId = kahootId
    }
    
}
