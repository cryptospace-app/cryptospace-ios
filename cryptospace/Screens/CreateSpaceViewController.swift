// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class CreateSpaceViewController: UIViewController {

    var kahootId: String!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func createButtonTapped(_ sender: Any) {
        Defaults.kahootId = kahootId
        let space = instantiate(SpaceViewController.self)
        space.kahootId = kahootId
        navigationController?.pushViewController(space, animated: true)
    }
    
}
