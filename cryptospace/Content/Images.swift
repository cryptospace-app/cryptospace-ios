// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

struct Images {
    
    static var okIndicator: UIImage { systemName("checkmark.circle") }
    static var errorIndicator: UIImage { systemName("exclamationmark.triangle") }
    
    private static func systemName(_ systemName: String) -> UIImage {
        return UIImage(systemName: systemName)!
    }
    
}
