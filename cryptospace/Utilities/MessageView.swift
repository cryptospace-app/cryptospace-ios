// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class MessageView: UIView {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    
    func setMessage(text: String, image: UIImage) {
        messageLabel.text = text
        messageImageView.image = image
    }
    
}
