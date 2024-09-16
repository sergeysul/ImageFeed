import UIKit

class OAuth2TokenStorage {
    let storage = UserDefaults.standard
    let key = "Bearer Token"

    var token: String? {
        get {
            storage.string(forKey: key)
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
