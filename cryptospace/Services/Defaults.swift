// Copyright © 2020 cryptospace. All rights reserved.

import Foundation

struct Defaults {
    
    private static let defaults = UserDefaults.standard
    
    static var privateKey: String? {
        get {
            return defaults.string(forKey: "private_key")
        }
        set {
            defaults.set(newValue, forKey: "private_key")
        }
    }
    
    static var kahootId: String? {
        get {
            return defaults.string(forKey: "kahoot_id")
        }
        set {
            defaults.set(newValue, forKey: "kahoot_id")
        }
    }
    
}
