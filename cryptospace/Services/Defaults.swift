// Copyright © 2020 cryptospace. All rights reserved.

import Foundation

struct Defaults {
    
    private static let defaults = UserDefaults.standard
    
    // For hack purposes. Not secure at all.
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
    
    static var name: String {
        get {
            return defaults.string(forKey: "name") ?? ""
        }
        set {
            defaults.set(newValue, forKey: "name")
        }
    }
    
}
