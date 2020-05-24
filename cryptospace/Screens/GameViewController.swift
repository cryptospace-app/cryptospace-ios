// Copyright © 2020 cryptospace. All rights reserved.

import UIKit
import WebKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Play"
        
        if let urlString = Defaults.kahootURL, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
}
