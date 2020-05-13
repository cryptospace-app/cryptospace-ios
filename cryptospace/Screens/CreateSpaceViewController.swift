// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class CreateSpaceViewController: UIViewController {

    var kahootId: String!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createButtonTapped(_ sender: Any) {
        let space = instantiate(SpaceViewController.self)
        space.kahootId = kahootId
        navigationController?.pushViewController(space, animated: true)
    }
    
}
