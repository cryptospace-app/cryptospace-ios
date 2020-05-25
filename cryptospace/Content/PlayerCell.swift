// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class PlayerCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    func setup(_ model: PlayerCellModel) {
        nameLabel.text = model.name
        scoreLabel.text = String(model.score)
        let meColor = UIColor.systemYellow.withAlphaComponent(0.3)
        backgroundColor = model.itsMe ? meColor : .clear
    }
    
}
